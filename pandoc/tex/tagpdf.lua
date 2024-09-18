-- Implements PDF tagging on the pandoc level.

local function tag_struct(elem, tag)
    local insert = table.insert
    if elem.insert then
        insert = elem.insert
    end

    insert(elem, 1, pandoc.RawInline('latex', '\\expandafter\\tagstructbegin{tag=' .. tag .. '}'))
    insert(elem, pandoc.RawInline('latex', '\\tagstructend'))
end

local function tag_content(elem, tag)
    local insert = table.insert
    if elem.insert then
        insert = elem.insert
    end

    insert(elem, 1, pandoc.RawInline('latex', '\\expandafter\\tagmcbegin{tag=' .. tag .. '}'))
    insert(elem, pandoc.RawInline('latex', '\\tagmcend'))
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

    tag = tag .. ",label={" .. pandoc.utils.stringify(elem.content) .. " \\thepage}"

    local result = {elem}
    tag_content(result, tag)
    tag_struct(result, tag)
    return result
end

local function List(elem)
    local ordering = "UnorderedList"
    if elem.tag == "OrderedList" then
        ordering = "OrderedList"
    end

    local content = {elem}
    tag_struct(content, "LI")
    tag_struct(content, "L,attribute=" .. ordering)

    local last = #elem.content
    for i, obj in ipairs(elem.content) do
        -- List body
        tag_content(obj, "LBody")
        tag_struct(obj, "LBody")

        -- LI code
        if i ~= last then
            obj:insert(pandoc.RawInline('latex', '\\tagstructend'))
            obj:insert(pandoc.RawInline('latex', '\\tagstructbegin{tag=LI}'))
        end
    end

    return content
end

return {
    {Pandoc = Pandoc},
    {Div = DivSidebar},
    {Para = Para, Div = Div, Header = Header, BulletList = List, OrderedList = List},
}