HTML = HTML
Table = Table
page = page

function add_hidden_text(elem)
    local elem_before = HTML.create_element("span", " [")
    HTML.add_class(elem_before, "select-only")
    HTML.set_attribute(elem_before, "aria-hidden", "true")
    HTML.prepend_child(elem, elem_before)

    local elem_after = HTML.create_element("span", "]")
    HTML.add_class(elem_after, "select-only")
    HTML.set_attribute(elem_after, "aria-hidden", "true")
    HTML.append_child(elem, elem_after)
end
Table.iter_values(add_hidden_text, HTML.select_all_of(page, { ".ability-head" }))
