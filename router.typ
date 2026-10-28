#import "templates/google-classic/template.typ": resume as google_classic_resume

#let get_template(template_name) = {
  if template_name == "google-classic" {
    google_classic_resume
  } else {
    panic("Неизвестный шаблон: " + template_name)
  }
}