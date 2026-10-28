#import "settings.typ": *

#let render_content(block_type, val) = {
  if block_type == "text" {
    val
  } else if block_type == "experience" {
    for job in val [
      *#job.company* — #job.role \
      #emph(job.date)
      #list(..job.points.map(p => [#p]))
      #v(0.5em)
    ]
  } else if block_type == "projects" {
    for proj in val [
      *#proj.name* — #proj.type
      #list(..proj.points.map(p => [#p]))
      Репозиторий: \
      #clink(proj.link)[#proj.link]
      #v(0.5em)
    ]
  } else if block_type == "education" {
    for edu in val [
      *#edu.institution* \
      #emph(edu.date) \
      #edu.degree
      #v(0.5em)
    ]
  } else if block_type == "portfolio" {
    clink(val)[#val]
  } else if block_type == "awards" {
    list(..val.map(award => [
      *#award.name*, \
      #for line in award.details.trim().split("\n").map(p => p.trim()).filter(p => p != "") [
        #line, \
      ]
    ]))
  } else if block_type == "skills" {
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

#let render_section(section) = [
  #section-heading(section.title)
  #render_content(section.type, section.data)
  #v(1em)
]

#let resume(data) = {
  show: apply-styles
  set text(lang: data.meta.lang)

  grid(
    columns: (auto, 1fr),
    align: (left + bottom, right + bottom),
    column-gutter: 1.5em,
    [ #text(size: 40pt, weight: "bold")[#data.meta.name] ],
    [ #align(left)[ #text(size: 12pt, weight: "bold")[
          #for contact in data.meta.contacts [ #contact \ ]
    ] ] ]
  )
  
  v(0.4em)
  
  text(size: 16pt, weight: "bold")[#data.meta.title]
  
  v(1em)

  // ===== ВЫВОД НА ВСЮ ШИРИНУ =====
  for section in data.center [
    #render_section(section)
  ]

  // ===== ДВУХКОЛОНОЧНАЯ СЕТКА =====
  if data.left.len() > 0 or data.right.len() > 0 [
    #grid(
      columns: (65%, 35%),
      gutter: 2em,
      [
        #for section in data.left [
          #render_section(section)
        ]
      ],
      [
        #for section in data.right [
          #render_section(section)
        ]
      ]
    )
  ]
}