local function add_class_chain(elem, class)
    if elem then
        HTML.add_class(elem, class)
    end
end

if not HTML.select_one(page, ".nav-gen ul") then
    add_class_chain(HTML.select_one(page, "#nav-sections"), "nav-mobile")
    add_class_chain(HTML.select_one(page, "#gen-menu"), "nav-nosize")
    for _, e in HTML.select(page, "#gen-menu > ul > li") do
        HTML.wrap(e, HTML.create_element("p"))
        HTML.unwrap(e)
    end
    Table.iter_values(HTML.unwrap, HTML.select(page, "#gen-menu > ul"))
    for _, e in HTML.select(page, "#menu-inner") do
        HTML.add_class(e, "dissolved-menu")
    end
    add_class_chain(HTML.select_one(page, "article"), "no-toc")
else
    add_class_chain(HTML.select_one(page, "article"), "has-toc")
end
