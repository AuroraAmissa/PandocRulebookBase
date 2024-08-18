for _, s in HTML.select(page, "body style") do
    HTML.append_child(HTML.select_one(page, "head") or unreachable(), s)
end

local styles = JSON.from_string(Sys.read_file("build/run/styles.json"))
for _, e in HTML.select(page, "styleLink") do
    HTML.delete(e)

    local element = HTML.create_element("link")
    HTML.set_attribute(element, "rel", "stylesheet")
    HTML.set_attribute(element, "type", "text/css")
    HTML.set_attribute(element, "href", styles[page_file])
    HTML.append_child(HTML.select_one(page, "head") or unreachable(), element)
end
