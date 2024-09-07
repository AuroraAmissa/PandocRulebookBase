local common = require 'PandocRulebookBase.pandoc.common'

local meta = common.read_json("build/pdf/meta.json")
local no_c_span_space = meta.pdf.no_c_span_space

function Span(elem)
    if elem.classes:includes("breadcrumbs") then
        return {}
    end

    if elem.classes:includes("c") then
        local is_fu = elem.classes:includes("fu")
        local ch_open = is_fu and "【" or "〔"
        local ch_close = is_fu and "】" or "〕"

        table.insert(elem.content, 1, ch_open)
        table.insert(elem.content, ch_close)

        if not no_c_span_space then
            return {
                pandoc.RawInline('latex', "\\hspace{-0.5em}"),
                elem,
                pandoc.RawInline('latex', "\\hspace{-0.5em}"),
            }
        else
            return elem
        end
    end
end
