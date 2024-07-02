local common = require 'PandocRulebookBase.pandoc.common'

local authors = {}
local title, override_created, override_modified

local function Meta(element)
    local author = element["author"]
    if pandoc.utils.type(author) == "Inlines" then
        table.insert(authors, pandoc.utils.stringify(author))
    elseif pandoc.utils.type(author) == "List" then
        for i = 1, #author do
            table.insert(authors, pandoc.utils.stringify(author[i]))
        end
    end

    if element["created"] then
        override_created = pandoc.utils.stringify(element["created"])
    end

    if element["modified"] then
        override_modified = pandoc.utils.stringify(element["modified"])
    end
end

local function Header(element)
    if element.level == 1 then
        title = pandoc.utils.stringify(element.content)
    end
end

local function run(cmd)
    local handle = io.popen(cmd)
    local output = handle:read("*all")
    handle:close()
    return output
end
local function split_created_modified(str)
    local split = str:split("\n")
    local created, earliest

    if #split == 1 and split[1] == "" then
        created = "1970-01-01T00:00:00Z"
        earliest = "1970-01-01T00:00:00Z"
    else
        created = split[#split]
        earliest = split[1]
    end

    return created, earliest
end
local function iso_to_short(str)
    return str:split("T")[1]
end

local function Span(span)
    if span.classes:includes("breadcrumbs") then
        local file_name = common.origin_file()

        local output = run("git log --follow --pretty=format:%cI " .. file_name)

        local created, modified = split_created_modified(output)

        if override_created then
            created = override_created
        end
        if override_modified then
            modified = override_modified
        end

        local meta_span = {}

        if #authors > 0 then
            table.insert(meta_span, "by ")
            for i = 1, #authors do
                if i ~= 1 then
                    table.insert(meta_span, pandoc.Str(" and "))
                end

                table.insert(meta_span, pandoc.RawInline("html", "<hcard class=p-author>"))
                table.insert(meta_span, authors[i])
                table.insert(meta_span, pandoc.RawInline("html", "</hcard>"))
            end
        end

        if #meta_span ~= 0 then
            table.insert(meta_span, pandoc.Str(" ⬩ "))
        end
        table.insert(meta_span, pandoc.RawInline("html", "<time class=dt-published datetime=\"" .. created .. "\">"))
        table.insert(meta_span, iso_to_short(created))
        table.insert(meta_span, pandoc.RawInline("html", "</time>"))

        if iso_to_short(created) ~= iso_to_short(modified) then
            table.insert(meta_span, pandoc.Str(" ⬩ "))
            table.insert(meta_span, "updated ")
            table.insert(meta_span, pandoc.RawInline("html", "<time class=dt-updated datetime=\"" .. modified .. "\">"))
            table.insert(meta_span, iso_to_short(modified))
            table.insert(meta_span, pandoc.RawInline("html", "</time>"))
        end

        if title and span.content[#span.content].text == "$" then
            span.content[#span.content] = title
        end
        span.content = { pandoc.Span(span.content), pandoc.Span(meta_span) }
    end
    return span
end

return { { Meta = Meta, Header = Header }, { Span = Span } }
