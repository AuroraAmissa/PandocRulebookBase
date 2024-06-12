function mark_zh(e)
    HTML.add_class(e, "zh")
end
Table.iter_values(mark_zh, HTML.select_all_of(page, { "article", "section" }))

function mark_lang(e)
    HTML.set_attribute(e, "lang", "zh")
end
Table.iter_values(mark_lang, HTML.select(page, "html"))
