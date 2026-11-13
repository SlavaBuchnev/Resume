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
MAIN_TYP = ROOT / "tools" / "main.typ"
INSPECT_TYP = ROOT / "tools" / "list.typ"


def run_typst(args):
    """Запускает typst из корня репозитория."""
    return subprocess.run(["typst"] + args, cwd=ROOT, capture_output=True, text=True)


def inspect_person(yml_path):
    """Читает файл пользователя и возвращает (templates, langs) или None.

    YAML парсит сам Typst (tools/list.typ через `typst eval`) — в стандартной
    библиотеке Python парсера нет, а внешние зависимости запрещены.
    """
    rel = yml_path.relative_to(ROOT).as_posix()
    cmd = [
        "eval", "query(<resume-config>)",
        "--in", str(INSPECT_TYP.relative_to(ROOT)),
        "--root", ".",
        "--input", f"data=/{rel}",
    ]
    result = run_typst(cmd)
    if result.returncode != 0:
        print(f"❌ Ошибка валидации {rel}:")
        print(result.stderr.strip())
        return None
    try:
        info = json.loads(result.stdout)[0]["value"]
        return info["templates"], info["langs"]
    except (json.JSONDecodeError, IndexError, KeyError, TypeError):
        print(f"❌ Не удалось разобрать ответ typst query для {rel}:")
        print(result.stdout.strip())
        return None


def find_resumes():
    """Ищет файлы users/*.yaml и раскладывает каждый на задачи сборки (шаблон × язык).

    Возвращает (задачи, была_ли_ошибка_валидации).
    """
    resumes = []
    had_errors = False

    if not USERS_DIR.exists():
        return resumes, had_errors

    for entry in sorted(USERS_DIR.iterdir()):
        if entry.is_dir():
            print(f"⚠️  {entry.relative_to(ROOT)}: старый формат не поддерживается. Нужен один файл users/{{фио}}.yaml")
            continue
        if entry.suffix == ".yml":
            print(f"⚠️  {entry.relative_to(ROOT)}: расширение .yml не поддерживается, переименуйте в .yaml")
            continue
        if not entry.is_file() or entry.suffix != ".yaml":
            continue

        info = inspect_person(entry)
        if info is None:
            had_errors = True
            continue
        templates, langs = info

        rel = entry.relative_to(ROOT).as_posix()
        for template in templates:
            for lang in langs:
                base = f"{template}_{lang}"
                resumes.append({
                    "user": entry.stem,
                    "template": template,
                    "lang": lang,
                    "base": base,
                    "yaml_path": rel,
                    "pdf_name": f"resume_{base}",
                })
    return resumes, had_errors


def compile_resume(resume, output_dir):
    """Компилирует одно резюме через Typst."""
    user_dir = output_dir / resume["user"]
    user_dir.mkdir(parents=True, exist_ok=True)
    out_pdf = user_dir / f"{resume['pdf_name']}.pdf"

    cmd = [
        "compile", str(MAIN_TYP.relative_to(ROOT)),
        str(out_pdf.relative_to(ROOT)),
        "--root", ".",
        "--input", f"data=/{resume['yaml_path']}",
        "--input", f"template={resume['template']}",
        "--input", f"lang={resume['lang']}",
    ]
    print(f"📄 {resume['user']} / {resume['base']}")
    result = run_typst(cmd)

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
    """Сборка. Если filters задан — собираем только указанные файлы users/*.yaml."""
    if SITE_DIR.exists():
        shutil.rmtree(SITE_DIR)
    SITE_DIR.mkdir(parents=True)

    all_resumes, scan_errors = find_resumes()
    if not all_resumes:
        print("⚠️  Не найдено ни одного резюме в users/ (нужны файлы users/*.yaml)")
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

    ok = not scan_errors
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
    p_build.add_argument("--filter", nargs="+", help="Список файлов users/*.yaml для сборки")

    args = parser.parse_args()

    if args.command == "build":
        build(args.filter)


if __name__ == "__main__":
    main()
