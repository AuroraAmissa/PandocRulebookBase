HTML = HTML
Table = Table
page = page

function process_menu_item(e)
    HTML.wrap(e, HTML.create_element("p"))
    HTML.unwrap(e)
end

if not HTML.select_one(page, ".nav-gen ul") then
    HTML.add_class(HTML.select_one(page, "#nav-sections"), "nav-mobile")
    HTML.add_class(HTML.select_one(page, "#gen-menu"), "nav-nosize")
    Table.iter_values(process_menu_item, HTML.select(page, "#gen-menu > ul > li"))
    Table.iter_values(HTML.unwrap, HTML.select(page, "#gen-menu > ul"))
end