#import "settings.typ": *

#let resume(data) = {
  show: apply-styles
  set text(lang: data.lang)

  // ===== ШАПКА =====
  grid(
    columns: (auto, 1fr),
    align: (left + bottom, right + bottom),
    column-gutter: 1.5em,
    [ #text(size: 40pt, weight: "bold")[#data.name] ],
    [ 
      #align(left)[ 
        #text(size: 12pt, weight: "bold")[
          #for contact in data.contacts [ 
            #contact \ 
          ]
        ] 
      ] 
    ]
  )
  
  v(0.4em)
  
  text(size: 16pt, weight: "bold")[#data.title]
  
  v(1em)

  // ===== ОСНОВНАЯ СЕТКА =====
  grid(
    columns: (65%, 35%),
    gutter: 2em,
    
    // ---------- ЛЕВАЯ КОЛОНКА ----------
    [
      #section-heading(data.exp_title)
      #for job in data.experience [
        *#job.company* — #job.role \
        #emph(job.date)
        #list(..job.points.map(p => [#p]))
        #v(0.5em)
      ]

      #section-heading(data.proj_title)
      #for proj in data.projects [
        *#proj.name* — #proj.type
        #list(..proj.points.map(p => [#p]))
        Репозиторий: \
        #clink(proj.link)[#proj.link]
        #v(0.5em)
      ]

      #section-heading(data.edu_title)
      #for edu in data.education [
        *#edu.institution* \
        #emph(edu.date) \
        #edu.degree
        #v(0.5em)
      ]
    ],

    // ---------- ПРАВАЯ КОЛОНКА ----------
    [
      #section-heading(data.port_title)
      #clink(data.portfolio)[#data.portfolio]
      #v(1em) 
    
            #section-heading(data.awards_title)
      #list(..data.awards.map(award => [
        *#award.name*, \
        #award.details.trim().split("\n").map(p => p.trim()).filter(p => p != "").map(p => [#p]).join([, \ ])
      ]))
      #v(1em)

      #section-heading(data.skills_title)
      #list(..data.skills.map(skill => {
        let skill_list = skill.at("list", default: "")
        
        if skill_list != "" and skill_list.trim() != "" [
          *#skill.category:* #skill_list
        ] else [
          *#skill.category*
        ]
      }))
    ]
  )
}