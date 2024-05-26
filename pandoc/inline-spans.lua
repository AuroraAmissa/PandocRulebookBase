local common = require 'PandocRulebookBase.pandoc.common'

local function class_u(elem)
    if elem.classes:includes("u") then
        elem.classes:insert("unnumbered")
        elem.classes:insert("unlisted")
    end
    return elem
end

function Span(span)
    span = class_u(span)

    -- we don't use css for this so it's selectable
    if span.classes:includes("calc") or span.classes:includes("c") then
        span.content:insert(1, pandoc.Str("〔"))
        span.content:insert(pandoc.Str("〕"))
    end

    return span
end

CodeBlock = class_u
Div = class_u
Figure = class_u
Header = class_u
Table = class_u
Code = class_u
Image = class_u
Link = class_u
