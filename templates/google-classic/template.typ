#import "settings.typ": *

#let render-text(val) = val

#let render-experience(val) = {
  for job in val [
    *#job.company* — #job.role \
    #emph(job.date)
    #list(..job.points.map(p => [#p]))
    #v(0.5em)
  ]
}

#let render-projects(val) = {
  for proj in val [
    *#proj.name* — #proj.type
    #list(..proj.points.map(p => [#p]))
    Репозиторий: \
    #clink(proj.link)[#proj.link]
    #v(0.5em)
  ]
}

#let render-education(val) = {
  for edu in val [
    *#edu.institution* \
    #emph(edu.date) \
    #edu.degree
    #v(0.5em)
  ]
}

#let render-portfolio(val) = {
  clink(val)[#val]
  
  v(1em)
}

#let render-awards(val) = {
  list(..val.map(award => [
    *#award.name*, \
    #for line in award.details.trim().split("\n").map(p => p.trim()).filter(p => p != "") [
      #line, \
    ]
  ]))
  
  v(1em)
}

#let render-skills(val) = {
  list(..val.map(skill => {
    let skill-list = skill.at("list", default: "")
    if skill-list != "" and skill-list.trim() != "" [
      *#skill.category:* #skill-list
    ] else [
      *#skill.category*
    ]
  }))
}

#let renderers = (
  text: render-text,
  experience: render-experience,
  projects: render-projects,
  education: render-education,
  portfolio: render-portfolio,
  awards: render-awards,
  skills: render-skills,
)

#let render-content(block-type, val) = {
  let renderer = renderers.at(block-type, default: none)
  if renderer == none {
    panic("Неизвестный тип секции: " + block-type + ". Доступные: " + renderers.keys().join(", "))
  }
  renderer(val)
}

#let render-section(section) = [
  #section-heading(section.title)
  #render-content(section.type, section.data)
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

  for section in data.center {
    render-section(section)
  }

  if data.left.len() > 0 or data.right.len() > 0 [
    #grid(
      columns: (65%, 35%),
      gutter: 2em,
      [
        #for section in data.left {
          render-section(section)
        }
      ],
      [
        #for section in data.right {
          render-section(section)
        }
      ]
    )
  ]
}