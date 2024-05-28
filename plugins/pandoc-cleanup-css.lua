local remove_classes = {
    "level1", "level2", "level3", "level4", "level5", "level6", -- redundant
    "u", "unlisted", "unnumbered", "ny" -- not used after generation
}

function do_remove(elem)
    HTML.remove_class(elem, target_class)
end
function remove(cl)
    target_class = cl
    Table.iter_values(do_remove, HTML.select(page, "." .. cl))
end
Table.iter_values(remove, remove_classes)

function aria_hidden(elem)
    HTML.remove_class(elem, "aria-hidden")
    HTML.set_attribute(elem, "aria-hidden", "true")
end
Table.iter_values(aria_hidden, HTML.select(page, ".aria-hidden"))
