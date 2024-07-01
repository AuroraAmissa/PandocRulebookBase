lang = config["lang"]

function mark_lang_class(e)
    HTML.add_class(e, lang)
end
Table.iter_values(mark_lang_class, HTML.select_all_of(page, { "article", "section" }))

function mark_lang(e)
    HTML.set_attribute(e, "lang", lang)
end
Table.iter_values(mark_lang, HTML.select(page, "html"))
