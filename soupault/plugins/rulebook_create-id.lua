for _, box in HTML.select(page, ".box") do
    for _, elem in HTML.select(box, "h6") do
        local slug = ""
        for _, child in HTML.children(elem) do
            if HTML.is_text(child) then
                slug = slug .. " " .. HTML.inner_text(child)
            end
        end
        HTML.set_attribute(elem, "id", String.slugify(string.trim(slug)))
    end
end
