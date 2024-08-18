HTML = HTML
Table = Table
page = page

function process_menu_item(e)
    HTML.wrap(e, HTML.create_element("p"))
    HTML.unwrap(e)
end

function process_menu_inner(e)
    HTML.add_class(e, "dissolved-menu")
end

local function add_class_chain(elem, class)
    if elem then
        HTML.add_class(elem, class)
    end
end

if not HTML.select_one(page, ".nav-gen ul") then
    add_class_chain(HTML.select_one(page, "#nav-sections"), "nav-mobile")
    add_class_chain(HTML.select_one(page, "#gen-menu"), "nav-nosize")
    Table.iter_values(process_menu_item, HTML.select(page, "#gen-menu > ul > li"))
    Table.iter_values(HTML.unwrap, HTML.select(page, "#gen-menu > ul"))
    Table.iter_values(process_menu_inner, HTML.select(page, "#menu-inner"))
    add_class_chain(HTML.select_one(page, "article"), "no-toc")
else
    add_class_chain(HTML.select_one(page, "article"), "has-toc")
end
