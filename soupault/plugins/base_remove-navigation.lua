-- Delete the navigation elements if there are subpages or a ToC.
local html = HTML.select_one(page, "#gen-toc li")
local has_toc = html and Table.length(HTML.children(html)) > 0
html = HTML.select_one(page, "#gen-subpages li")
local has_subpages = html and Table.length(HTML.children(html)) > 0

if has_subpages then
    Table.iter_values(HTML.delete, HTML.select(page, "#nav-sections, #gen-menu, #subpages-hr"))
elseif has_toc then
    Table.iter_values(HTML.delete, HTML.select(page, "#nav-sections, #gen-menu, #nav-hr"))
end
