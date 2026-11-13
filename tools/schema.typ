// ==========================================
// СХЕМЫ ДАННЫХ
// ==========================================

// Схема элемента для типов, где data = массив объектов
#let item-schemas = (
  experience: (
    company: str,
    role: str,
    date: str,
    points: array,   // массив строк
  ),
  projects: (
    name: str,
    type: str,
    link: str,
    points: array,
  ),
  education: (
    institution: str,
    date: str,
    degree: str,
  ),
  awards: (
    name: str,
    details: str,
  ),
  skills: (
    category: str,
    list: str,
  ),
)

#let array-types = ("experience", "projects", "education", "awards", "skills")
#let scalar-types = ("text", "portfolio")
#let valid-types = array-types + scalar-types
#let column-names = ("center", "left", "right")
#let reserved-root-fields = ("templates",)

// ==========================================
// ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
// ==========================================

#let is-empty(val) = {
  if val == none { return true }
  if type(val) == str and val.trim() == "" { return true }
  if type(val) == array and val.len() == 0 { return true }
  false
}

// Человеко-читаемое имя типа
#let type-name(t) = {
  if t == str { "string" }
  else if t == array { "array" }
  else if t == dictionary { "dictionary" }
  else if t == int { "integer" }
  else if t == float { "float" }
  else if t == bool { "boolean" }
  else if t == none { "none" }
  else { repr(t) }
}

#let fail(msg) = panic("Ошибка валидации → " + msg)

#let sorted-keys(dict) = dict.keys().sorted()

// ==========================================
// ВАЛИДАТОРЫ
// ==========================================

// Проверка одного элемента массива (например, одной записи опыта)
#let validate-item(item, schema, path) = {
  if type(item) != dictionary {
    fail(path + ": ожидался словарь, получено " + type-name(type(item)))
  }

  // Проверка на неизвестные поля (защита от опечаток)
  for key in item.keys() {
    if key not in schema {
      fail(path + ": неизвестное поле '" + key + "'. Допустимые: " + schema.keys().join(", "))
    }
  }

  // Проверка обязательных полей
  for (key, expected) in schema {
    if key not in item {
      fail(path + ": отсутствует обязательное поле '" + key + "'")
    }
    let val = item.at(key)
    if type(val) != expected {
      fail(path + "." + key + ": ожидался " + type-name(expected) + ", получен " + type-name(type(val)))
    }
    // Для массивов проверяем, что каждый элемент — строка
    if expected == array {
      for i in range(val.len()) {
        if type(val.at(i)) != str {
          fail(path + "." + key + "[" + str(i) + "]: ожидалась строка, получено " + type-name(type(val.at(i))))
        }
      }
    }
  }
}

// Проверка одного блока (title + type + data)
#let validate-block(block, path) = {
  if type(block) != dictionary {
    fail(path + ": блок должен быть словарём")
  }

  // Проверка на неизвестные поля блока
  for key in block.keys() {
    if key not in ("title", "type", "data") {
      fail(path + ": неизвестное поле '" + key + "'. Допустимые: title, type, data")
    }
  }

  for key in ("title", "type", "data") {
    if key not in block {
      fail(path + ": отсутствует поле '" + key + "'")
    }
  }

  let title = block.at("title")
  let block-type = block.at("type")
  let data = block.at("data")

  if type(title) != str {
    fail(path + ".title: ожидалась строка")
  }
  if title.trim() == "" {
    fail(path + ".title: заголовок не может быть пустым")
  }

  if type(block-type) != str {
    fail(path + ".type: ожидалась строка")
  }
  if block-type not in valid-types {
    fail(path + ".type: неизвестный тип '" + block-type + "'. Допустимые: " + valid-types.join(", "))
  }

  // Валидация data в зависимости от типа
  if block-type in array-types {
    if type(data) != array {
      fail(path + ".data: для типа '" + block-type + "' ожидался массив")
    }
    let schema = item-schemas.at(block-type)
    for i in range(data.len()) {
      validate-item(data.at(i), schema, path + ".data[" + str(i) + "]")
    }
  } else {
    if type(data) != str {
      fail(path + ".data: для типа '" + block-type + "' ожидалась строка")
    }
  }

  // Возвращаем ADT: типизированный блок
  (type: block-type, title: title, data: data)
}

// Проверка метаданных секции языка (name, title, contacts)
#let validate-meta(raw, path) = {
  for key in raw.keys() {
    if key not in ("name", "title", "contacts", "blocks") {
      fail(path + ": неизвестное поле '" + key + "'. Допустимые: name, title, contacts, blocks")
    }
  }

  for key in ("name", "title", "contacts", "blocks") {
    if key not in raw {
      fail(path + ": отсутствует обязательное поле '" + key + "'")
    }
  }

  let name = raw.at("name")
  let title = raw.at("title")
  let contacts = raw.at("contacts")

  if type(name) != str { fail(path + ".name: ожидалась строка") }
  if type(title) != str { fail(path + ".title: ожидалась строка") }
  if type(contacts) != array { fail(path + ".contacts: ожидался массив") }

  if name.trim() == "???" {
    fail(path + ".name: поле не заполнено (стоит '???')")
  }
  if title.trim() == "???" {
    fail(path + ".title: поле не заполнено (стоит '???')")
  }

  for i in range(contacts.len()) {
    if type(contacts.at(i)) != str {
      fail(path + ".contacts[" + str(i) + "]: ожидалась строка")
    }
  }

  (name: name, title: title, contacts: contacts)
}

// Проверка секции одного языка: meta + именованные блоки
#let validate-lang(raw, lang, path) = {
  let lang-path = path + "." + lang
  if type(raw) != dictionary {
    fail(lang-path + ": секция языка должна быть словарём (name, title, contacts, blocks)")
  }

  let meta = validate-meta(raw, lang-path)

  let blocks = raw.at("blocks")
  if type(blocks) != dictionary {
    fail(lang-path + ".blocks: ожидался словарь имён блоков")
  }
  if blocks.len() == 0 {
    fail(lang-path + ".blocks: должен быть хотя бы один блок")
  }

  let validated = (:)
  for name in blocks.keys() {
    let block-path = lang-path + ".blocks." + name
    validated.insert(name, validate-block(blocks.at(name), block-path))
  }

  (meta: meta, blocks: validated)
}

// Проверка раскладки одного шаблона: колонки center/left/right → списки имён блоков
#let validate-layout(raw, template, blocks, path) = {
  let layout-path = path + ".templates." + template
  if type(raw) != dictionary {
    fail(layout-path + ": раскладка должна быть словарём колонок (center / left / right)")
  }

  for key in raw.keys() {
    if key not in column-names {
      fail(layout-path + ": неизвестная колонка '" + key + "'. Допустимые: " + column-names.join(", "))
    }
  }
  if raw.len() == 0 {
    fail(layout-path + ": укажите хотя бы одну колонку со списком блоков")
  }

  let layout = (:)
  let used = ()
  for column in column-names {
    if column not in raw { continue }

    let names = raw.at(column)
    if type(names) != array {
      fail(layout-path + "." + column + ": ожидался массив имён блоков")
    }
    for i in range(names.len()) {
      let name = names.at(i)
      let name-path = layout-path + "." + column + "[" + str(i) + "]"
      if type(name) != str {
        fail(name-path + ": ожидалась строка — имя блока")
      }
      if name not in blocks {
        fail(name-path + ": неизвестный блок '" + name + "'. Доступные: " + sorted-keys(blocks).join(", "))
      }
      if name in used {
        fail(layout-path + ": блок '" + name + "' указан в раскладке дважды")
      }
      used.push(name)
    }
    layout.insert(column, names)
  }

  if used.len() == 0 {
    fail(layout-path + ": не указано ни одного блока")
  }

  layout
}

// Полная проверка файла пользователя: языки, блоки, шаблоны и раскладки
#let validate-config(raw, path: "yaml") = {
  if type(raw) != dictionary {
    fail(path + ": корень YAML должен быть словарём (секции языков + ключ 'templates')")
  }

  let lang-names = raw.keys().filter(k => k not in reserved-root-fields)
  if lang-names.len() == 0 {
    fail(path + ": не найдено ни одной секции языка (добавьте, например, 'ru:')")
  }

  if "templates" not in raw {
    fail(path + ": отсутствует обязательное поле 'templates'")
  }

  let langs = (:)
  for lang in lang-names {
    langs.insert(lang, validate-lang(raw.at(lang), lang, path))
  }

  // Раскладка общая для всех языков, поэтому набор блоков должен совпадать
  let reference-names = sorted-keys(langs.at(lang-names.at(0)).blocks)
  for lang in lang-names {
    let current = sorted-keys(langs.at(lang).blocks)
    if current != reference-names {
      fail(
        path + "." + lang + ": набор блоков должен совпадать во всех языках. "
          + "Ожидался: " + reference-names.join(", ") + ". "
          + "Получен: " + current.join(", ")
      )
    }
  }

  let templates-raw = raw.at("templates")
  if type(templates-raw) != dictionary {
    fail(path + ".templates: ожидался словарь шаблонов")
  }
  if templates-raw.len() == 0 {
    fail(path + ".templates: укажите хотя бы один шаблон")
  }

  let templates = (:)
  for template in templates-raw.keys() {
    let layout = validate-layout(templates-raw.at(template), template, langs.at(lang-names.at(0)).blocks, path)
    templates.insert(template, layout)
  }

  // Каждый блок должен использоваться хотя бы в одном шаблоне
  let referenced = ()
  for template in templates.keys() {
    for column in column-names {
      for name in templates.at(template).at(column, default: ()) {
        if name not in referenced {
          referenced.push(name)
        }
      }
    }
  }
  let unused = reference-names.filter(name => name not in referenced)
  if unused.len() > 0 {
    fail(path + ": блоки не использованы ни в одном шаблоне: " + unused.join(", "))
  }

  (langs: langs, templates: templates)
}

// Выбор одного резюме из проверенного конфига: язык + шаблон.
// Возвращает структуру (meta, center, left, right), которую потребляет шаблон.
#let select-resume(config, lang: none, template: none) = {
  if lang == none {
    lang = config.langs.keys().at(0)
  }
  if lang not in config.langs {
    panic("Язык '" + lang + "' не найден в файле. Доступные: " + config.langs.keys().join(", "))
  }

  if template == none {
    template = config.templates.keys().at(0)
  }
  if template not in config.templates {
    panic("Шаблон '" + template + "' не указан в файле. Доступные: " + config.templates.keys().join(", "))
  }

  let lang-data = config.langs.at(lang)
  let layout = config.templates.at(template)

  let columns = (center: (), left: (), right: ())
  for column in column-names {
    for name in layout.at(column, default: ()) {
      let block = lang-data.blocks.at(name)
      if is-empty(block.data) { continue }
      columns.at(column).push(block)
    }
  }

  (
    meta: lang-data.meta + (lang: lang),
    center: columns.center,
    left: columns.left,
    right: columns.right,
  )
}
