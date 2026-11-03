#import "settings.typ": *

// ==========================================
// РЕНДЕР КАЖДОГО ТИПА СЕКЦИИ
// ==========================================
#let render-content(block_type, val) = {
  // -------- TEXT --------
  // Просто абзац текста. Используется для "Обо мне", "Саммари".
  if block_type == "text" {
    val
  }

  // -------- EXPERIENCE --------
  // Массив записей: company, role, date, points[]
  else if block_type == "experience" {
    for job in val [
      #grid(
        columns: (1fr, auto),
        [*#job.company* — #job.role],
        [#emph(job.date)],
      )
      #list(..job.points.map(p => [#p]))
      #v(0.5em)
    ]
  }

  // -------- PROJECTS --------
  // Массив записей: name, type, link, points[]
  else if block_type == "projects" {
    for proj in val [
      *#proj.name* — #proj.type
      #list(..proj.points.map(p => [#p]))
      Link: #clink(proj.link)[#proj.link]
      #v(0.5em)
    ]
  }

  // -------- EDUCATION --------
  // Массив записей: institution, date, degree
  else if block_type == "education" {
    for edu in val [
      #grid(
        columns: (1fr, auto),
        [*#edu.institution*],
        [#emph(edu.date)],
      )
      #edu.degree
      #v(0.4em)
    ]
  }

  // -------- PORTFOLIO --------
  // Одна строка — ссылка.
  else if block_type == "portfolio" {
    clink(val)[#val]
  }

  // -------- AWARDS --------
  // Массив записей: name, details (может быть многострочным)
  else if block_type == "awards" {
    list(..val.map(award => [
      *#award.name*, \
      #for line in award.details.trim().split("\n").map(p => p.trim()).filter(p => p != "") [
        #line, \
      ]
    ]))
  }

  // -------- SKILLS --------
  // Массив записей: category, list (list может быть пустым)
  else if block_type == "skills" {
    list(..val.map(skill => {
      let skill_list = skill.at("list", default: "")
      if skill_list != "" and skill_list.trim() != "" [
        *#skill.category:* #skill_list
      ] else [
        *#skill.category*
      ]
    }))
  }
}

#let render-section(section) = [
  #section-heading(section.title)
  #render-content(section.type, section.data)
]

// ==========================================
// ГЛАВНАЯ ФУНКЦИЯ
// ==========================================
#let resume(data) = {
  show: apply-styles
  set text(lang: data.meta.lang)

  // ===== ШАПКА (по центру) =====
  align(center)[
    #text(size: 22pt, weight: "bold")[#data.meta.name]     // было 20pt
    #v(0.3em)
    #text(size: 12pt)[#data.meta.title]
  ]
  
  v(0.5em)
  
  align(center)[
    #text(size: 10pt)[
      #data.meta.contacts.join("  •  ")
    ]
  ]
  
  v(0.8em)
  
  line(length: 100%, stroke: 1pt)
  
  v(0.4em)

  // ===== ВСЕ СЕКЦИИ В ОДНУ КОЛОНКУ =====
  for section in data.center { render-section(section) }
  for section in data.left { render-section(section) }
  for section in data.right { render-section(section) }
}