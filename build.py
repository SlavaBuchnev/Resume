#!/usr/bin/env python3
import argparse
import json
import os
import shutil
import subprocess
import sys
import http.server
import socketserver
from pathlib import Path

ROOT = Path(__file__).parent.resolve()
USERS_DIR = ROOT / "users"
TEMPLATES_DIR = ROOT / "templates"
WEB_DIR = ROOT / "web"
SITE_DIR = ROOT / "_site"


def find_resumes():
    """Ищет все YAML-файлы в users/."""
    resumes = []
    if not USERS_DIR.exists():
        return resumes
        
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
        # Выводим понятную ошибку от Typst
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


def build():
    """Полная сборка: PDF + JSON + web."""
    if SITE_DIR.exists():
        shutil.rmtree(SITE_DIR)
    SITE_DIR.mkdir(parents=True)

    resumes = find_resumes()
    if not resumes:
        print("⚠️  Не найдено ни одного резюме в users/")
        sys.exit(1)

    ok = True
    for r in resumes:
        if not compile_resume(r, SITE_DIR):
            ok = False

    generate_json(resumes, SITE_DIR)
    copy_web(SITE_DIR)

    if ok:
        print(f"\n✅ Готово: {SITE_DIR}/")
    else:
        print("\n⚠️  Сборка завершена с ошибками. Исправьте YAML-файлы.")
        sys.exit(1)


def serve():
    """Запускает HTTP-сервер на localhost:8000."""
    os.chdir(SITE_DIR)
    handler = http.server.SimpleHTTPRequestHandler
    with socketserver.TCPServer(("", 8000), handler) as httpd:
        print("🌐 Сервер запущен: http://localhost:8000 (Ctrl+C чтобы остановить)")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n👋 Сервер остановлен")


def get_dir_state():
    """Возвращает словарь с временем модификации файлов для отслеживания изменений."""
    state = {}
    for folder in [USERS_DIR, TEMPLATES_DIR, WEB_DIR]:
        if folder.exists():
            for p in folder.rglob("*"):
                if p.is_file():
                    state[p] = p.stat().st_mtime
    return state


def main():
    parser = argparse.ArgumentParser(description="Build tool для платформы резюме на Typst")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("build", help="Собрать всё в _site/")
    sub.add_parser("serve", help="Собрать и открыть на localhost:8000")

    args = parser.parse_args()

    if args.command == "build":
        build()
    elif args.command == "serve":
        build()
        serve()


if __name__ == "__main__":
    main()