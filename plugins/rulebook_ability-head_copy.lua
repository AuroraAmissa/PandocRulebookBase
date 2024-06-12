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
Table.iter_values(add_hidden_text, HTML.select(page, ".ability-head"))

function fix_section_in_ability(elem)
    local text = HTML.inner_text(elem)
    Table.iter_values(HTML.delete, HTML.children(elem))

    local new_span = HTML.create_element("span", text)
    HTML.add_class(new_span, "section-for-ability")
    HTML.append_child(HTML.parent(elem), new_span)
end
Table.iter_values(fix_section_in_ability, HTML.select(page, ".box .section"))