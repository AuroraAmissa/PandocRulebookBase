local common = require 'PandocRulebookBase.pandoc.common'

function Div(div)
    if div.classes:includes("ability") or div.classes:includes("sidebar") then
        div.classes:insert("box")
        return div
    end
end

function Header(elem)
    if elem.classes:includes("u") then
        elem.classes:insert("unnumbered")
        elem.classes:insert("unlisted")
        return elem
    end
end
