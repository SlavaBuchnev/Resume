#let template_name = sys.inputs.at("template", default: "google-classic")
#let data_path = sys.inputs.at("data")

#let data = yaml(data_path)

#if template_name == "google-classic" {
  // Убрали # внутри блока кода
  import "templates/google-classic/template.typ": resume
  resume(data)
} else {
  panic("Unknown template: " + template_name)
}