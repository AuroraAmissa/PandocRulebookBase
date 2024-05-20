local common = require 'PandocRulebookBase.pandoc.common'

function Span(span)
    -- we don't use css for this so it's selectable
    if span.classes:includes("calc") or span.classes:includes("c") then
        span.content:insert(1, pandoc.Str("〔"))
        span.content:insert(pandoc.Str("〕"))
        return span
    end
end
