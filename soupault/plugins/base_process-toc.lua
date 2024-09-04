-- Process excluded headings
local unlisted_ids = {}
for _, element in HTML.select(page, ".unlisted, .notoc, h4, h5, h6") do
    local attr = HTML.get_attribute(element, "id")
    if attr then
        unlisted_ids["#" .. attr] = 1
    end
end

-- Process toc and exclude references that are excluded
local elem_toc = HTML.select_one(page, "#gen-toc")
if elem_toc then
    for _, element in HTML.select(elem_toc, "li") do
        local link = HTML.select_one(element, "a")
        if link then
            local target = HTML.get_attribute(link, "href")
            if target then
                if unlisted_ids[target] then
                    HTML.delete(element)
                end
            end
        end
    end
end

-- Check and process the subpages section.
local elem_subpages = HTML.select_one(page, "#subpages-section")
if elem_subpages then
    -- Copy the subpages to the navigation bar
    local content = HTML.clone(elem_subpages)

    Table.iter_values(HTML.delete, HTML.select(content, "h2, h3, h4, h5, h6"))
    local subpages = HTML.select_one(page, "#gen-subpages")
    if subpages then
        HTML.append_child(subpages, content)
        HTML.unwrap(content)
    end
else
    -- Delete the subpage headings
    Table.iter_values(HTML.delete, HTML.select(page, "#gen-subpages, #nav-subpages, #subpages-hr"))
end

-- Delete the `#nav-hr` if there is no (remaining) table of contents
local html = HTML.select_one(page, "#gen-toc li")
if not html or Table.length(HTML.children(html)) == 0 then
    Table.iter_values(HTML.delete, HTML.select(page, "#nav-hr, #nav-banner-toc, #gen-toc"))
end

-- Delete remaining empty .toc elements
while true do
    local any_deleted = false
    for _, element in HTML.select(page, ".toc") do
        if Table.length(HTML.children(element)) == 0 then
            HTML.delete(element)
            any_deleted = true
        end
    end
    if not any_deleted then
        break
    end
end
