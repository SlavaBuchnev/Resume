# Resume Platform на Typst

Платформа для создания и автоматической публикации PDF-резюме. Разделяет дизайн и контент, поддерживает нескольких пользователей, языки и шаблоны. Работает на чистом Python и Typst без установки сторонних библиотек.

**Сайт-визитка:** [Slavabuchev.github.io/Resume](https://Slavabuchev.github.io/Resume/)

## 📂 Структура проекта
```text
├── templates/            # Шаблоны верстки
│   └── template/   # Название шаблона
│       ├── settings.typ  # Стили (шрифты, цвета)
│       └── template.typ  # Макет (верстка)
├── users/                # Резюме пользователей
│   └── v.s.buchnev/      # Папка пользователя (ФИО)
│       └──  {template_name}_{lang}.yaml
├── web/                  # Исходники сайта-визитки (HTML/CSS/JS)
├── main.typ              # Контроллер: валидация YAML и подготовка данных
├── router.typ            # Выбор шаблона (коммутатор)
├── build.py              # Скрипт локальной сборки (без внешних зависимостей)
└── .github/workflows/    # CI/CD пайплайны (deploy + validate)
```

## 📝 Как добавить свое резюме
1. Создайте папку со своим именем в директории `users/` (например, `users/i.i.ivanov/`).
2. Выберите шаблон в папке `templates/`
3. Переименуйте его по формуле `{template}_{lang}.yaml` (например, `google-classic_ru.yaml`).
4. Заполните данные в YAML-файле.
   > ⚠️ **Важно:** Используйте только пробелы для отступов (не Tab). Строки с `@` или `+` берите в кавычки. Не оставляйте текст `???` (платформа не даст собрать PDF с пустыми полями).

### 🎨 Как работает верстка
Вы сами управляете структурой резюме. В YAML-файле есть три секции:
* `left` — блоки в левую колонку.
* `right` — блоки в правую колонку.
* `center` — блоки на всю ширину страницы.

Каждый блок имеет свой `title` (заголовок, который вы можете назвать как угодно) и `type` (тип отрисовки: `experience`, `projects`, `skills`, `text` и т.д.).

5. Сделайте Pull Request. GitHub Actions автоматически проверит файл на ошибки и, если всё ок, опубликует PDF на сайте.

## 🛠️ Локальная сборка и компиляция
Для работы нужен только [Typst](https://github.com/typst/typst) и Python 3 (сторонние библиотеки **не требуются**).

### Вариант 1: Использовать скрипт (Рекомендуемый)
```bash
# Собрать все PDF и сгенерировать сайт в папку _site/
python build.py build

# Собрать и запустить локальный сервер на http://localhost:8000
python build.py serve
```

### Вариант 2: Ручная компиляция одного PDF
Если вы хотите собрать только один файл без генерации сайта:

```bash
typst compile main.typ output.pdf --root . \
  --input data="users/v.s.buchnev/google-classic_ru.yaml" \
  --input template="google-classic"
```

## ⚙️ CI/CD
* **При пуше в `main`** срабатывает `deploy.yml`: собирает все PDF, генерирует `resumes.json` и публикует сайт на GitHub Pages.
* **При создании Pull Request** срабатывает `validate.yml`: проверяет, что новые YAML-файлы корректны и не ломают сборку (благодаря валидации в `main.typ`).

## 🎨 Как добавить новый шаблон (для мейнтейнера)
1. Создайте папку `templates/your-template-name/`.
2. Добавьте `settings.typ` и `template.typ`. В `template.typ` функция `resume(data)` должна принимать подготовленный объект с ключами `meta`, `center`, `left`, `right`.
3. В файле `router.typ` добавьте импорт нового шаблона и условие:
   ```typst
   #import "templates/your-template-name/template.typ": resume as your_template_resume
   
   #let get_template(template_name) = {
     // ... 
     } else if template_name == "your-template-name" {
       your_template_resume
     }
   }
   ```
