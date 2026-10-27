#set page(
  paper: "a4",
  margin: (left: 0.5cm, right: 1cm, top: 1.5cm, bottom: 1.5cm),
)

#set text(font: ("Times New Roman", "Liberation Serif"), size: 10pt, lang: "ru")
#set par(justify: false, leading: 0.55em)

// Функция для синих подчеркнутых ссылок
#let clink(url, body) = link(
  url,
  underline(text(fill: rgb("#0055CC"), body))
)

// Функция для заголовков секций (синий текст)
#let section-heading(title) = block(width: 100%, above: 1.2em, below: 0.5em)[
  #text(size: 11pt, weight: "bold", fill: rgb("#2B579A"))[#upper(title)]
]