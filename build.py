#!/usr/bin/env python3
import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).parent.resolve()
USERS_DIR = ROOT / "users"
WEB_DIR = ROOT / "web"
SITE_DIR = ROOT / "_site"


def find_resumes():
    """Ищет все YAML-файлы в users/."""
    if not USERS_DIR.exists():
        return []
    resumes = []
    for user_dir in sorted(USERS_DIR.iterdir()):
        if not user_dir.is_dir():
            continue
        for yaml_file in sorted(user_dir.glob("*.yaml")):
            base = yaml_file.stem
            if "_" not in base:
                print(f"⚠️  {yaml_file}: имя должно быть {{template}}_{{lang}}.yaml")
                continue
            template, lang = base.rsplit("_", 1)
            resumes.append({
                "user": user_dir.name,
                "template": template,
                "lang": lang,
                "base": base,
                "yaml_path": str(yaml_file.relative_to(ROOT)),
                "pdf_name": f"resume_{base}",
            })
    return resumes


def compile_resume(resume, output_dir):
    """Компилирует одно резюме через Typst."""
    user_dir = output_dir / resume["user"]
    user_dir.mkdir(parents=True, exist_ok=True)
    out_pdf = user_dir / f"{resume['pdf_name']}.pdf"

    cmd = [
        "typst", "compile", "main.typ",
        str(out_pdf.relative_to(ROOT)),
        "--root", ".",
        "--input", f"data={resume['yaml_path']}",
        "--input", f"template={resume['template']}",
    ]
    print(f"📄 {resume['user']} / {resume['base']}")
    result = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)

    if result.returncode != 0:
        print(f"❌ Ошибка при сборке {resume['base']}:")
        print(result.stderr.strip())
        return False
    return True


def generate_json(resumes, output_dir):
    """Создает resumes.json, сгруппированный по пользователям."""
    data = {}
    for r in resumes:
        data.setdefault(r["user"], []).append(r["pdf_name"])
    with open(output_dir / "resumes.json", "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print("📝 Сгенерирован resumes.json")


def copy_web(output_dir):
    """Копирует файлы сайта из web/ в output_dir."""
    if not WEB_DIR.exists():
        return
    for item in WEB_DIR.iterdir():
        dest = output_dir / item.name
        if item.is_dir():
            if dest.exists():
                shutil.rmtree(dest)
            shutil.copytree(item, dest)
        else:
            shutil.copy2(item, dest)
    print("🌐 Скопированы файлы сайта")


def build(filters=None):
    """Сборка. Если filters задан — собираем только указанные YAML."""
    if SITE_DIR.exists():
        shutil.rmtree(SITE_DIR)
    SITE_DIR.mkdir(parents=True)

    all_resumes = find_resumes()
    if not all_resumes:
        print("⚠️  Не найдено ни одного резюме в users/")
        sys.exit(1)

    if filters:
        # Нормализуем пути (могут прийти как ./users/x.yaml или users/x.yaml)
        filter_set = {Path(f).as_posix().lstrip("./") for f in filters}
        to_compile = [r for r in all_resumes if r["yaml_path"] in filter_set]
        print(f"🔍 Фильтр: собираем {len(to_compile)} из {len(all_resumes)}")
        if not to_compile:
            print("⚠️  Ни один файл не попал под фильтр. Проверьте пути.")
            sys.exit(1)
    else:
        to_compile = all_resumes

    ok = True
    for r in to_compile:
        if not compile_resume(r, SITE_DIR):
            ok = False

    # JSON всегда для всех, чтобы сайт показывал полный список
    generate_json(all_resumes, SITE_DIR)
    copy_web(SITE_DIR)

    if ok:
        print(f"\n✅ Готово: {SITE_DIR}/")
    else:
        print("\n⚠️  Сборка завершена с ошибками. Исправьте YAML-файлы.")
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(description="Build tool для платформы резюме на Typst")
    sub = parser.add_subparsers(dest="command", required=True)

    p_build = sub.add_parser("build", help="Собрать резюме в _site/")
    p_build.add_argument("--filter", nargs="+", help="Список YAML-файлов для сборки")

    args = parser.parse_args()

    if args.command == "build":
        build(args.filter)


if __name__ == "__main__":
    main()