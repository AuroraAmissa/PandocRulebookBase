-- Implements PDF tagging on the pandoc level.

local function tag_struct(elem, tag)
    table.insert(elem, 1, pandoc.RawInline('latex', '\\tagstructbegin{tag=' .. tag .. '}'))
    table.insert(elem, pandoc.RawInline('latex', '\\tagstructend'))
end

local function tag_content(elem, tag)
    table.insert(elem, 1, pandoc.RawInline('latex', '\\tagmcbegin{tag=' .. tag .. '}'))
    table.insert(elem, pandoc.RawInline('latex', '\\tagmcend'))
end

local function Pandoc(doc)
    local newblocks = pandoc.structure.make_sections(doc.blocks)
    doc.blocks = newblocks
    return doc
end

local function Para(elem)
    tag_content(elem.content, "P")
    tag_struct(elem.content, "P")
    return elem
end

local function DivSidebar(elem)
    if elem.classes:includes("sidebar") then
        tag_struct(elem.content, "Aside")
        for _, obj in ipairs(elem.content) do
            if obj.tag == "Div" and obj.classes:includes("section") then
                obj.classes = obj.classes:filter(function(x) return x ~= "section" end)
            end
        end
        return elem
    end
end

local function Div(elem)
    if elem.classes:includes("section") then
        tag_struct(elem.content, "Sect")
        return elem
    end
end

local function Header(elem)
    local tag = "H" .. elem.level

    if elem.classes:includes("tex_h1") then
        tag = "H1"
    end
    if elem.classes:includes("tex_h2") then
        tag = "H2"
    end
    if elem.classes:includes("tex_h3") then
        tag = "H3"
    end
    if elem.classes:includes("tex_h4") then
        tag = "H4"
    end

    local result = {elem}
    tag_content(result, tag)
    tag_struct(result, tag)
    return result
end

return {
    {Pandoc = Pandoc},
    {Div = DivSidebar},
    {Para = Para, Div = Div, Header = Header},
}