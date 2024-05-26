local remove_classes = {
    "level1", "level2", "level3", "level4", "level5", "level6", -- redundant
    "u", "unlisted", "unnumbered" -- not used after generation
}

function do_remove(elem)
    HTML.remove_class(elem, target_class)
end
function remove(cl)
    target_class = cl
    Table.iter_values(do_remove, HTML.select(page, "." .. cl))
end
Table.iter_values(remove, remove_classes)
