#import "templates/google-classic/template.typ": resume as google_classic_resume
#import "templates/harvard/template.typ": resume as harvard_resume

#let templates = (
  google-classic: google_classic_resume,
  harvard: harvard_resume,
)

#let get_template(name) = {
  if name in templates {
    templates.at(name)
  } else {
    panic("Неизвестный шаблон: " + name + ". Доступные: " + templates.keys().join(", "))
  }
}