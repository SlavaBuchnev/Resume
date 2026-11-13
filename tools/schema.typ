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
#let known-root-fields = ("lang", "name", "title", "contacts", "sections")

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

// Проверка одного блока секции (title + type + data)
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

#let validate-meta(raw, path) = {
  if type(raw) != dictionary {
    fail(path + ": корень YAML должен быть словарём")
  }
  
  for key in raw.keys() {
    if key not in known-root-fields {
      fail(path + ": неизвестное поле '" + key + "'. Допустимые: " + known-root-fields.join(", "))
    }
  }
  
  for key in ("name", "title", "contacts", "sections") {
    if key not in raw {
      fail(path + ": отсутствует обязательное поле '" + key + "'")
    }
  }
  
  let name = raw.at("name")
  let title = raw.at("title")
  let lang = raw.at("lang", default: "en")
  let contacts = raw.at("contacts")
  
  if type(name) != str { fail(path + ".name: ожидалась строка") }
  if type(title) != str { fail(path + ".title: ожидалась строка") }
  if type(lang) != str { fail(path + ".lang: ожидалась строка") }
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
  
  (lang: lang, name: name, title: title, contacts: contacts)
}

#let validate-sections(raw, path) = {
  let sections = raw.at("sections")
  if type(sections) != dictionary {
    fail(path + ".sections: ожидался словарь (left / right / center)")
  }
  
  let center = ()
  let left = ()
  let right = ()
  
  for side in sections.keys() {
    if side not in ("left", "right", "center") {
      fail(path + ".sections: неизвестная колонка '" + side + "'. Допустимые: left, right, center")
    }
    
    let blocks = sections.at(side)
    if type(blocks) != array {
      fail(path + ".sections." + side + ": ожидался массив блоков")
    }
    
    for i in range(blocks.len()) {
      let block-path = path + " sections." + side + "[" + str(i) + "]"
      let validated = validate-block(blocks.at(i), block-path)
      
      if is-empty(validated.data) { continue }
      
      if side == "center" {
        center += (validated,)
      } else if side == "left" {
        left += (validated,)
      } else {
        right += (validated,)
      }
    }
  }
  
  (center: center, left: left, right: right)
}

#let validate-resume(raw, path: "yaml") = {
  let meta = validate-meta(raw, path)
  let sections = validate-sections(raw, path)
  
  (
    meta: meta,
    center: sections.center,
    left: sections.left,
    right: sections.right,
  )
}