#import "router.typ": get_template
#import "schema.typ": validate-config, select-resume

#let lang = sys.inputs.at("lang", default: none)
#let template_name = sys.inputs.at("template", default: none)
#let data_path = sys.inputs.at("data")

#let config = validate-config(yaml(data_path), path: data_path)

// Если язык/шаблон не переданы — берём первые из файла (удобно для ручной компиляции)
#let lang = if lang == none { config.langs.keys().at(0) } else { lang }
#let template_name = if template_name == none { config.templates.keys().at(0) } else { template_name }

#let data = select-resume(config, lang: lang, template: template_name)

#let render = get_template(template_name)
#render(data)
