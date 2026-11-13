# Resume Platform на Typst

Платформа для создания и автоматической публикации PDF-резюме. Разделяет дизайн и контент: контент каждого пользователя хранится в одном YAML-файле, а шаблоны (Typst) задают только вёрстку. Один и тот же контент можно публиковать в разных шаблонах и на разных языках. Работает на чистом Python и Typst без установки сторонних библиотек.

**Сайт-визитка:** [Slavabuchev.github.io/Resume](https://slavabuchnev.github.io/Resume/)

## 📂 Структура проекта
```text
├── templates/            # Шаблоны вёрстки
│   └── {name}/           # Название шаблона
│       ├── settings.typ  # Стили (шрифты, цвета)
│       └── template.typ  # Макет (функция resume(data))
├── users/                # Резюме пользователей: один файл {фио}.yaml на человека
│   ├── example.yaml      # Демонстрационный файл (образец для заполнения)
│   └── v.s.buchnev.yaml
├── web/                  # Исходники сайта-визитки (HTML/CSS/JS)
├── tools/                # Весь код на Typst (компиляция и валидация)
│   ├── main.typ          # Контроллер: валидация YAML и подготовка данных
│   ├── schema.typ        # Схемы данных и валидатор
│   ├── router.typ        # Выбор шаблона (коммутатор)
│   └── list.typ          # Служебный файл: список шаблонов/языков для build.py
├── build.py              # Скрипт сборки (без внешних зависимостей)
└── .github/workflows/    # CI/CD пайплайны (deploy + validate)
```

## 📝 Как добавить своё резюме
1. Создайте файл `users/{фио}.yaml` (например, `users/i.i.ivanov.yaml`).
2. Опишите контент: секция на каждый язык (`ru:`, `en:`, ...), внутри — `name`, `title`, `contacts` и словарь именованных блоков `blocks`.
3. В ключе `templates:` перечислите шаблоны и раскладку: какие блоки в какие колонки (`center` / `left` / `right`) класть. Порядок имён в списке = порядок блоков в PDF.
4. Сделайте Pull Request. GitHub Actions автоматически проверит файл на ошибки и, если всё ок, опубликует PDF на сайте.

Подробности о процессе — в [CONTRIBUTING.md](CONTRIBUTING.md).

### Формат файла
```yaml
ru:
  name: "Иван Примеров"
  title: "BACKEND-РАЗРАБОТЧИК"
  contacts:
    - "+7(999)000-00-00"
    - "example@example.com"

  blocks:
    about:
      type: text
      title: "ОБО МНЕ"
      data: "Короткий текст о себе"
    experience:
      type: experience
      title: "ОПЫТ РАБОТЫ"
      data:
        - company: "ООО Ромашка"
          role: "Backend-разработчик"
          date: "январь 2023 – настоящее время"
          points:
            - "Разработал микросервисы на Go."
    skills:
      type: skills
      title: "НАВЫКИ"
      data:
        - category: "Go"
          list: "gin, gorm"

templates:
  google-classic:
    center: [about]
    left: [experience]
    right: [skills]
  harvard:
    center: [about, experience, skills]
```

### Правила
* ⚠️ Используйте только пробелы для отступов (не Tab). Строки с `@` или `+` берите в кавычки. Не оставляйте текст `???` (платформа не даст собрать PDF с пустыми полями).
* Набор имён блоков (`blocks`) должен совпадать во всех языках — раскладка `templates:` общая для всех языков.
* Каждый блок должен использоваться хотя бы в одном шаблоне, иначе сборка упадёт с ошибкой.
* Типы блоков с `data`-массивом: `experience`, `projects`, `education`, `awards`, `skills`; типы со строкой: `text`, `portfolio`.
* Полный пример — в `users/example.yaml`.

## 🛠️ Локальная сборка и компиляция
Для работы нужен только [Typst](https://github.com/typst/typst) и Python 3 (сторонние библиотеки **не требуются**).

### Вариант 1: Использовать скрипт (рекомендуемый)
```bash
# Собрать все PDF и сгенерировать сайт в папку _site/
python3 build.py build

# Собрать только одного пользователя
python3 build.py build --filter users/v.s.buchnev.yaml

# Посмотреть результат: поднять сервер из _site/
cd _site && python3 -m http.server 8000
```

### Вариант 2: Ручная компиляция одного PDF
Если вы хотите собрать только один PDF без генерации сайта:

```bash
typst compile tools/main.typ output.pdf --root . \
  --input data="/users/v.s.buchnev.yaml" \
  --input template="google-classic" \
  --input lang="ru"
```
Если `lang` или `template` не указаны, возьмутся первые из файла. Путь в `data` начинается с `/` — он задаётся от корня репозитория (файл `main.typ` лежит в `tools/`).

## ⚙️ CI/CD
* **При пуше в `main`** срабатывает `deploy.yml`: собирает все PDF, генерирует `resumes.json` и публикует сайт на GitHub Pages.
* **При создании Pull Request** срабатывает `validate.yml`: проверяет, что новые файлы резюме корректны и не ломают сборку (благодаря валидации в `tools/schema.typ`).
