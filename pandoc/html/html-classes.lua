function Div(elem)
    if elem.classes:includes("twocolumn") then
        return elem.content
    end

    if elem.classes:includes("twocolumnfill") then
        return elem.content
    end
end