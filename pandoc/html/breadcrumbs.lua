local common = require 'PandocRulebookBase.pandoc.common'

local authors = {}
local ogl_authors = {}
local title, override_created, override_modified

local modified_mode = common.read_json("build/run/soupault.json")["custom_options"]["modified_mode"]

local function push_to(arr, data)
    if pandoc.utils.type(data) == "Inlines" then
        table.insert(arr, pandoc.utils.stringify(data))
    elseif pandoc.utils.type(data) == "List" then
        for i = 1, #data do
            table.insert(arr, pandoc.utils.stringify(data[i]))
        end
    end
end

local function Meta(element)
    push_to(authors, element["author"])
    push_to(ogl_authors, element["ogl_author"])

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

local function push_authors(meta_span, list, author_class)
    local class = (author_class or "") and " class=p-author"

    for i = 1, #list do
        if i ~= 1 then
            table.insert(meta_span, pandoc.Str(" and "))
        end

        table.insert(meta_span, pandoc.RawInline("html", "<hcard" .. class .. ">"))
        table.insert(meta_span, list[i])
        table.insert(meta_span, pandoc.RawInline("html", "</hcard>"))
    end
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
            push_authors(meta_span, authors, true)
        end

        if #ogl_authors > 0 then
            if #meta_span ~= 0 then
                table.insert(meta_span, pandoc.Str(" ⬩ "))
            end
            table.insert(meta_span, "OGL by ")
            push_authors(meta_span, ogl_authors, false)
        end

        if modified_mode == "regular" then
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
        elseif modified_mode == "version" then
            --TODO: Implement some day
        elseif modified_mode == "none" then
            -- Intentionally left blank
        else
            error("Unknown modified mode: " .. modified_mode)
        end

        if title and span.content[#span.content].text == "$" then
            span.content[#span.content] = title
        end
        span.content = { pandoc.Span(span.content), pandoc.Span(meta_span) }
    end
    return span
end

return { { Meta = Meta, Header = Header }, { Span = Span } }
