function mark_lang(e)
    HTML.set_attribute(e, "lang", "jp")
end
Table.iter_values(mark_lang, HTML.select(page, "html"))
