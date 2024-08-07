HTML = HTML
Table = Table
page = page


-- Force ability heads to the end of the headings
function move_ability_head(element)
    local parent = HTML.parent(element)

    local text = HTML.children(parent)
    if text then
        HTML.append_child(parent, HTML.create_text(String.trim(HTML.inner_text(text[1]))))
        HTML.append_child(parent, element)

        HTML.delete(text[1])
    end
end
Table.iter_values(move_ability_head, HTML.select_all_of(page, { ".ability-head" }))

-- Remove section tags from subabilities
function subability_no_subsection(element)
    Table.iter_values(HTML.delete, HTML.select_all_of(element, { ".section" }))
end
Table.iter_values(subability_no_subsection, HTML.select_all_of(page, { ".subability" }))

-- Add hidden [x] text for ability heads
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

-- Fix section markers in abilities to appear in the proper place.
function fix_section_in_ability(elem)
    local text = HTML.inner_text(elem)
    Table.iter_values(HTML.delete, HTML.children(elem))

    local new_span = HTML.create_element("span", text)
    HTML.add_class(new_span, "section-for-ability")
    HTML.append_child(HTML.parent(elem), new_span)
end
Table.iter_values(fix_section_in_ability, HTML.select(page, ".box .section"))

-- Add the markers for calc blocks.
function add_calc_markings(elem)
    HTML.prepend_child(elem, HTML.create_text("〔"))
    HTML.append_child(elem, HTML.create_text("〕"))
end
Table.iter_values(add_calc_markings, HTML.select_all_of(page, { ".c", ".calc" }))
