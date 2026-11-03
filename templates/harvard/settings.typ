#let apply-styles(doc) = {
  set page(
    paper: "a4",
    margin: (left: 1.5cm, right: 1.5cm, top: 1.5cm, bottom: 1.5cm),
  )
  set text(font: "Liberation Serif", size: 10pt)
  set par(justify: true, leading: 0.5em)
  doc
}

#let clink(url, body) = link(url, underline(body))

#let section-heading(title) = block(width: 100%, above: 1em, below: 0.4em)[
  #text(size: 11pt, weight: "bold")[#upper(title)]
  #v(-0.35em)
  #line(length: 100%, stroke: 0.5pt)
  #v(-0.15em)
]