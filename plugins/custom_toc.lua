-- Process excluded headings
unlisted_ids = {}
function process_unlisted(element)
    local attr = HTML.get_attribute(element, "id")
    if attr then
        unlisted_ids["#" .. attr] = 1
    end
end
Table.iter_values(process_unlisted, HTML.select_all_of(page, { ".unlisted", "h4", "h5", "h6" }))

-- Process toc and exclude references that are excluded
local html = HTML.select_one(page, "#gen-toc")
function process_entries(element)
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
if html then
    Table.iter_values(process_entries, HTML.select(html, "li"))
end

-- Check and process the subpages section.
local html = HTML.select_one(page, "#subpages-section")
if html then
    -- Copy the subpages to the navigation bar
    local content = HTML.clone_content(html)
    Table.iter_values(HTML.delete, HTML.select_all_of(content, {"h2", "h3", "h4", "h5", "h6"}))
    HTML.append_child(HTML.select_one(page, "#gen-subpages"), content)
else
    -- Delete the subpage headings
    Table.iter_values(HTML.delete, HTML.select_all_of(page, {"#gen-subpages", "#nav-subpages", "#subpages-hr"}))
end

-- Force ability heads to the end of the headings
function move_ability_head(element)
    local parent = HTML.parent(element)

    local text = HTML.children(parent)
    HTML.append_child(parent, HTML.create_text(String.trim(HTML.inner_text(text[1]))))
    HTML.append_child(parent, element)

    HTML.delete(text[1])
end
Table.iter_values(move_ability_head, HTML.select_all_of(page, {".ability-head"}))

-- Remove section tags from subabilities
function subability_no_subsection(element)
    Table.iter_values(HTML.delete, HTML.select_all_of(element, {".section"}))
end
Table.iter_values(subability_no_subsection, HTML.select_all_of(page, {".subability"}))

-- Delete the `#nav-hr` if there is no (remaining) table of contents
local html = HTML.select_one(page, "#gen-toc li")
if not html or Table.length(HTML.children(html)) == 0 then
    Table.iter_values(HTML.delete, HTML.select_all_of(page, {"#nav-hr", "#nav-banner-toc", "#gen-toc"}))
end

-- Delete remaining empty .toc elements
function delete_empty_toc(element)
    if Table.length(HTML.children(element)) == 0 then
        HTML.delete(element)
    end
end
Table.iter_values(delete_empty_toc, HTML.select_all_of(page, {".toc"}))
