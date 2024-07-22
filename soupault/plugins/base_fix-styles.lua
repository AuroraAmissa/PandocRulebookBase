function move_style(s)
    HTML.append_child(HTML.select_one(page, "head"), s)
end
Table.iter_values(move_style, HTML.select(page, "body style"))

styles = JSON.from_string(Sys.read_file("build/run/styles.json"))
function style_link(e)
    HTML.delete(e)

    local element = HTML.create_element("link")
    HTML.set_attribute(element, "rel", "stylesheet")
    HTML.set_attribute(element, "type", "text/css")
    HTML.set_attribute(element, "href", styles[page_file])
    HTML.append_child(HTML.select_one(page, "head"), element)
end
Table.iter_values(style_link, HTML.select(page, "styleLink"))