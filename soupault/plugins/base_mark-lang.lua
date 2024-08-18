local lang = config["lang"]

for _, e in HTML.select(page, "article,section") do
    HTML.add_class(e, lang)
end

for _, e in HTML.select(page, "html") do
    HTML.set_attribute(e, "lang", lang)
end
