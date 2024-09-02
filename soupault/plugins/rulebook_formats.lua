-- Force ability heads to the end of the headings
for _, element in HTML.select(page, ".ability-head") do
    local parent = HTML.parent(element)

    if parent and HTML.children(parent) then
        if HTML.has_class(parent, "marked") then
            HTML.prepend_child(parent, element)
            HTML.add_class(element, "marked-head")
        else
            HTML.append_child(parent, element)
        end

        local section = HTML.select_one(parent, ".section")
        if section then
            HTML.prepend_child(parent, section)
        end
    end
end

-- Remove section tags from subabilities
for _, element in HTML.select(page, ".subability") do
    Table.iter_values(HTML.delete, HTML.select(element, ".section"))
end

-- Add hidden [x] text for ability heads
for _, elem in HTML.select(page, ".ability-head") do
    if HTML.has_class(elem, "marked-head") then
        local elem_after = HTML.create_element("span", " | ")
        HTML.add_class(elem_after, "select-only")
        HTML.set_attribute(elem_after, "aria-hidden", "true")
        HTML.append_child(elem, elem_after)
    else
        local elem_before = HTML.create_element("span", " [")
        HTML.add_class(elem_before, "select-only")
        HTML.set_attribute(elem_before, "aria-hidden", "true")
        HTML.prepend_child(elem, elem_before)

        local elem_after = HTML.create_element("span", "]")
        HTML.add_class(elem_after, "select-only")
        HTML.set_attribute(elem_after, "aria-hidden", "true")
        HTML.append_child(elem, elem_after)
    end
end

-- Fix section markers in abilities to appear in the proper place.
for _, elem in HTML.select(page, ".box .section") do
    local text = HTML.inner_text(elem)
    Table.iter_values(HTML.delete, HTML.children(elem))

    local new_span = HTML.create_element("span", text)
    HTML.add_class(new_span, "section-for-box")
    HTML.append_child(HTML.parent(elem) or unreachable(), new_span)

    if HTML.has_class(elem, ".ability-head") then
        local parent = HTML.parent(elem)
        if not parent or not HTML.has_class(parent, "marked") then
            HTML.add_class(new_span, "section-for-ability")
        end
    end
end

-- Unwrap sections in boxes.
Table.iter_values(HTML.unwrap, HTML.select(page, ".box > section:not(.ability)"))

-- Fix subability headers
for _, elem in HTML.select(page, ".box > p > .h7") do
    Table.iter_values(HTML.delete, HTML.select(elem, ".section"))
    HTML.unwrap(HTML.parent(elem) or unreachable())

    HTML.remove_class(elem, "h7")
    local wrapper = HTML.create_element("div")
    HTML.add_class(wrapper, "h7")
    HTML.wrap(elem, wrapper)
    HTML.set_tag_name(elem, "div")
end

-- Add the markers for calc blocks.
local c_open = soupault_config["custom_options"]["c_open"]
local c_close = soupault_config["custom_options"]["c_close"]
for _, elem in HTML.select(page, ".c, .calc") do
    if HTML.has_class(elem, "fu") then
        HTML.prepend_child(elem, HTML.create_text("【"))
        HTML.append_child(elem, HTML.create_text("】"))
    else
        HTML.prepend_child(elem, HTML.create_text(c_open))
        HTML.append_child(elem, HTML.create_text(c_close))
    end
end
