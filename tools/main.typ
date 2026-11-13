#import "router.typ": get_template
#import "schema.typ": validate-resume

#let template_name = sys.inputs.at("template", default: "google-classic")
#let data_path = sys.inputs.at("data")

#let raw_data = yaml(data_path)
#let data = validate-resume(raw_data, path: data_path)

#let render = get_template(template_name)
#render(data)