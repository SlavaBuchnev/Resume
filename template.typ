#import "settings.typ": *

#let resume(
  lang: "en", // Язык по умолчанию
  name: "",
  title: "",
  contacts: (),
  exp_title: "", proj_title: "", edu_title: "", 
  port_title: "", awards_title: "", skills_title: "",
  experience: (), projects: (), education: (), 
  portfolio: (), awards: (), skills: (),
) = {
  show: apply-styles
  set text(lang: lang)

  // ===== ШАПКА =====
  grid(
    columns: (auto, 1fr),
    align: (left + bottom, right + bottom),
    column-gutter: 1.5em,
    [ #text(size: 40pt, weight: "bold")[#name] ],
    [ #align(left)[ #text(size: 12pt, weight: "bold")[#contacts] ] ]
  )
  
  v(0.4em)
  text(size: 16pt, weight: "bold")[#title]
  v(1em)

  grid(
    columns: (65%, 35%),
    gutter: 2em,
    
    // ---------- ЛЕВАЯ КОЛОНКА ----------
    [
      #section-heading(exp_title)
      #experience

      #section-heading(proj_title)
      #projects

      #section-heading(edu_title)
      #education
    ],

    // ---------- ПРАВАЯ КОЛОНКА ----------
    [
      #section-heading(port_title)
      #portfolio
      
      #v(1em)
    
      #section-heading(awards_title)
      #awards
      
      #v(1em)

      #section-heading(skills_title)
      #skills
    ]
  )
}