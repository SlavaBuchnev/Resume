
# Резюме на Typst

Исходный код моего резюме, свёрстанный на [Typst](https://typst.app/). Проект настроен на автоматическую сборку PDF-версии и публикацию веб-версии (HTML) на GitHub Pages.

## 🚀 Ссылки
* **Сайт (HTML):** `https://Slavabuchev.github.io/Resume/`
* **Скачать PDF:** Доступен в разделе **Actions** -> выберите последний успешный запуск -> **Artifacts** -> `resume-pdf`.

## 📂 Структура проекта
* `main.typ` — основной файл с текстом резюме.
* `settings.typ` — настройки стилей (шрифты, цвета, отступы, заголовки).
* `.github/workflows/deploy.yml` — CI/CD пайплайн для сборки PDF и деплоя HTML.

## 🛠️ Локальная сборка
Для сборки необходим установленный [Typst](https://github.com/typst/typst).

**Собрать PDF:**
```bash
typst compile main.typ resume.pdf
```

**Собрать HTML:**
```bash
typst compile main.typ --features html --format html index.html
```

*Совет: для удобной работы используйте VS Code с расширением **Tinymist Typst** (живой предпросмотр по `Ctrl+K V`).*

## ⚙️ Автоматизация (GitHub Actions)
При каждом пуше в ветку `main` запускается workflow, который:
1. Параллельно компилирует `resume.pdf` и `index.html`.
2. Загружает PDF в артефакты GitHub Actions.
3. Публикует HTML-версию на GitHub Pages.
