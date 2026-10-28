#import "router.typ": get_template

#let template_name = sys.inputs.at("template", default: "google-classic")
#let data_path = sys.inputs.at("data")

#let raw_data = yaml(data_path)

#let is-empty(val) = {
  if val == none { return true }
  if type(val) == str and val.trim() == "" { return true }
  if type(val) == array and val.len() == 0 { return true }
  false
}

#let prepare_data(raw) = {
  let safe_get(key, default: "") = if key in raw { raw.at(key) } else { default }
  
  let meta = (
    lang: safe_get("lang", default: "en"),
    name: safe_get("name", default: "Unknown"),
    title: safe_get("title", default: ""),
    contacts: safe_get("contacts", default: ())
  )

  let center = ()
  let left = ()
  let right = ()

  if "sections" in raw {
    let sec = raw.sections
    
    if "center" in sec {
      for block in sec.center {
        if not is-empty(block.at("data", default: none)) {
          center.push(block)
        }
      }
    }
    if "left" in sec {
      for block in sec.left {
        if not is-empty(block.at("data", default: none)) {
          left.push(block)
        }
      }
    }
    if "right" in sec {
      for block in sec.right {
        if not is-empty(block.at("data", default: none)) {
          right.push(block)
        }
      }
    }
  }

  (
    meta: meta,
    center: center,
    left: left,
    right: right
  )
}

#let data = prepare_data(raw_data)
#let render = get_template(template_name)
#render(data)