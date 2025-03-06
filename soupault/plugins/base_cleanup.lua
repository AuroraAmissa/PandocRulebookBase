local remove_classes = {
    "nav-gen", "marked-head", -- used only during generation
    "level1", "level2", "level3", "level4", "level5", "level6", -- redundant
    "u", "unlisted", "unnumbered", "ny", "metaimage" -- not used after generation
}

for _, cl in remove_classes do
    for _, elem in HTML.select(page, "." .. cl) do
        HTML.remove_class(elem, cl)
    end
end

for _, elem in HTML.select(page, ".aria-hidden") do
    HTML.remove_class(elem, "aria-hidden")
    HTML.set_attribute(elem, "aria-hidden", "true")
end

for _, elem in HTML.select(page, ".internal:not(section)") do
    HTML.delete(elem)
end

for _, elem in HTML.select(page, ".internal") do
    HTML.remove_class(elem, "internal")
end
