# Resume Platform на Typst

Платформа для создания и автоматической публикации PDF-резюме. Разделяет дизайн и контент, поддерживает несколько пользователей, языков и шаблонов.

**Сайт-визитка:** [Slavabuchev.github.io/Resume](https://Slavabuchev.github.io/Resume/)

## 📂 Структура проекта
```text
├── templates/            # Шаблоны верстки
│   └── template/         # Название шаблона
│       ├── settings.typ  # Стили (шрифты, цвета)
│       ├── template.typ  # Макет (сетка, верстка)
│       └── example.yaml  # Пример заполнения данных
├── users/                # Резюме пользователей
│   └── v.s.buchnev/      # Папка пользователя (И. О. Фамилия)
│       └── {template}_{lang}.yaml
├── web/                  # Исходники сайта-визитки (HTML/CSS/JS)
├── main.typ              # Универсальная точка входа (парсит YAML)
├── build.py              # Скрипт локальной сборки и генерации сайта
└── .github/workflows/    # CI/CD пайплайны (deploy + validate)
```

## 📝 Как добавить свое резюме
1. Создайте папку со своим именем в директории `users/` (например, `users/i.i.ivanov/`).
2. Выберите шаблон в папке `templates/`
3. Скопируйте файл `example.yaml` из папки шаблона в свою папку.
4. Переименуйте его по формуле `{template}_{lang}.yaml` (например, `google-classic_ru.yaml`).
5. Отредактируйте данные в YAML-файле. 
   > ⚠️ **Важно:** Используйте только пробелы для отступов (не Tab). Строки с `@` или `+` берите в кавычки.
6. Сделайте Pull Request. GitHub Actions автоматически проверит файл на ошибки и, если всё ок, опубликует PDF на сайте.

## 🛠️ Локальная разработка
Для работы нужен [Typst](https://github.com/typst/typst) и Python 3.

```bash
# Собрать все PDF и сгенерировать сайт в папку _site/
python build.py build

# Собрать и запустить локальный сервер на http://localhost:8000
python build.py serve
```

## ⚙️ CI/CD
* **При пуше в `main`** срабатывает `deploy.yml`: собирает все PDF, генерирует `resumes.json` и публикует сайт на GitHub Pages.
* **При создании Pull Request** срабатывает `validate.yml`: проверяет, что новые YAML-файлы корректны и не ломают сборку.

## 🎨 Как добавить новый шаблон (для мейнтейнера)
1. Создайте папку `templates/your-template-name/`.
2. Добавьте `settings.typ` (стили) и `template.typ` (макет).
3. Положите рядом файл `example.yaml` с примером заполнения.
4. В файле `main.typ` добавьте условие для нового шаблона:
   ```typst
   } else if template_name == "your-template-name" {
     import "templates/your-template-name/template.typ": resume
     resume(data)
   ```