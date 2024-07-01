HTML = HTML
Table = Table
JSON = JSON
Regex = Regex
Sys = Sys
page = page

alt = JSON.from_string(Sys.read_file("build/run/alt.json"))
function append_tooltip(tt)
    local raw_text = HTML.inner_text(tt)
    local text = HTML.inner_text(tt)
    if HTML.has_class(tt, "ny") then
        text = alt[text .. "_ny"]
    else
        text = alt[text]
    end
    if not text then
        error("No such tooltip: " .. HTML.inner_text(tt))
    end

    HTML.remove_class(tt, "alt")
    HTML.add_class(tt, "tt-tx")
    Table.iter_values(HTML.delete, HTML.children(tt))
    HTML.append_child(tt, HTML.create_text(Regex.replace(raw_text, "\\(.*\\)", "")))

    local wrap_elem = HTML.create_element("span")
    HTML.add_class(wrap_elem, "alt")
    HTML.wrap(tt, wrap_elem)

    local tt_in = HTML.create_element("span", text)
    HTML.add_class(tt_in, "tt-in")

    local tt_wr = HTML.create_element("span")
    HTML.add_class(tt_wr, "tt-wr")
    HTML.set_attribute(tt_wr, "aria-hidden", "true")

    HTML.append_child(tt_wr, tt_in)
    HTML.append_child(wrap_elem, tt_wr)
end
Table.iter_values(append_tooltip, HTML.select_all_of(page, { ".alt" }))
