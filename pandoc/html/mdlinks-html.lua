local common = require 'PandocRulebookBase.pandoc.common'

local pages = pandoc.json.decode(common.read_file("build/extract/pages.json"))

function Link(el)
    if el.target and not el.target:startswith("http") then
        local components = el.target:split("#")

        local target = components[1]
        local section = components[2]

        local linkName = pandoc.utils.stringify(el.content)
        if target and target == "" then
            if pages[linkName:lower()] then
                target = linkName:lower()
            else
                error("No such link " .. linkName)
            end
        end
        if target and pages[target:lower()] then
            target = "../" .. pages[target:lower()]:gsub("%.md", ".html")
        end

        if section then
            if section == "" then
                section = linkName
            end
            section = section:lower():gsub("%%20", "-")
            target = target .. "#" .. section
        end

        el.target = target
    end

    return el
end
