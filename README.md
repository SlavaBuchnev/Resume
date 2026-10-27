# Резюме

Исходный код моего резюме на [Typst](https://typst.app/). Поддерживает несколько языков и автоматически публикует PDF-версии на GitHub Pages.

## 🚀 Ссылки
* **Сайт-визитка:** [Slavabuchev.github.io/Resume](https://Slavabuchev.github.io/Resume/)
* **Резюме (PDF):** [🇷🇺 Русский](https://Slavabuchev.github.io/Resume/resume_ru.pdf) | [🇬🇧 English](https://Slavabuchev.github.io/Resume/resume_en.pdf)

## 📂 Структура
* `template.typ` — макет (верстка и сетка).
* `settings.typ` — стили (шрифты, цвета).
* `lang/` — тексты резюме на разных языках.
* `web/` — сайт-визитка (HTML/CSS) для GitHub Pages.

## 🛠️ Локальная сборка
```bash
# Собрать русскую версию
typst compile lang/ru.typ resume_ru.pdf --root

# Собрать английскую версию
typst compile lang/en.typ resume_en.pdf --root
```

*Для живого предпросмотра в VS Code используйте расширение **Tinymist Typst** (`Ctrl+K V`).*

## ⚙️ CI/CD
При пуше в `main` GitHub Actions параллельно собирает PDF для всех языков из `matrix`, добавляет файлы из папки `web/` и деплоит результат на GitHub Pages. 

*Чтобы добавить новый язык, создайте файл в `lang/`, добавьте его в `matrix` внутри `deploy.yml` и создайте кнопку в `web/index.html`.*
