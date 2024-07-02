local common = require 'PandocRulebookBase.pandoc.common'

local pages = common.read_json("build/run/pages.json")
local clean_urls = common.read_json("build/run/soupault.json")["settings"]["clean_urls"]

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
            target = pages[target:lower()]
        end

        if not target:startswith("/") and not target:startswith(".") then
            if clean_urls then
                target = "/" .. target
            else
                target = common.relative_to("", common.short_path(), target)
            end
        end

        if section then
            if section == "" then
                section = linkName
            end
            section = section:lower():gsub("%%20", "-"):gsub(" ", "-")
            target = target .. "#" .. section
        end

        el.target = target
    end

    return el
end
