// Служебный файл для build.py: перечисляет языки и шаблоны файла пользователя.
// build.py вызывает `typst eval 'query(<resume-config>)' --in tools/list.typ`,
// чтобы узнать, какие PDF собирать (в стандартной библиотеке Python нет YAML-парсера).
#import "schema.typ": validate-config

#let data_path = sys.inputs.at("data")
#let display-path = if data_path.starts-with("/") { data_path.slice(1) } else { data_path }
#let config = validate-config(yaml(data_path), path: display-path)

#metadata((
  langs: config.langs.keys(),
  templates: config.templates.keys(),
)) <resume-config>
