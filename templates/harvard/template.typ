#import "settings.typ": *

#let render-text(val) = val

#let render-experience(val) = {
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

#let render-projects(val) = {
  for proj in val [
    *#proj.name* — #proj.type
    #list(..proj.points.map(p => [#p]))
    Link: #clink(proj.link)[#proj.link]
    #v(0.5em)
  ]
}

#let render-education(val) = {
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

#let render-portfolio(val) = clink(val)[#val]

#let render-awards(val) = {
  list(..val.map(award => [
    *#award.name*, \
    #for line in award.details.trim().split("\n").map(p => p.trim()).filter(p => p != "") [
      #line, \
    ]
  ]))
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

  align(center)[
    #text(size: 22pt, weight: "bold")[#data.meta.name]
    #v(0.3em)
    #text(size: 12pt)[#data.meta.title]
  ]
  
  v(0.5em)
  
  align(center)[
    #text(size: 10pt)[#data.meta.contacts.join("  •  ")]
  ]
  
  v(0.8em)
  
  line(length: 100%, stroke: 1pt)
  
  v(0.4em)

  for section in data.center { render-section(section) }
  for section in data.left { render-section(section) }
  for section in data.right { render-section(section) }
}