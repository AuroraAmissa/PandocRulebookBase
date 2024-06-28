local common = require 'PandocRulebookBase.pandoc.common'

local author = nil
local title = nil

function Meta(element)
    author = element["author"]
end

function Header(element)
    if element.level == 1 then
        title = pandoc.utils.stringify(element.content)
    end
end

function Span(span)
    if span.classes:includes("breadcrumbs") then
        local file_name = PANDOC_STATE.input_files[1]

        local handle = io.popen("git log --pretty=format:%cd --date=short " .. file_name)
        local output = handle:read("*all")
        handle:close()

        handle = io.popen("git log --pretty=format:%cI --date=short " .. file_name)
        local output_iso = handle:read("*all")
        handle:close()

        local output = output:split("\n")
        local output_iso = output_iso:split("\n")
        local earliest, earliest_iso, latest, latest_iso

        if #output == 1 and output[1] == "" then
            earliest = "XXXX-XX-XX"
            latest = "XXXX-XX-XX"
            earliest_iso = "XXXX-XX-XX"
            latest_iso = "XXXX-XX-XX"
        else
            earliest = output[#output]
            latest = output[1]
            earliest_iso = output_iso[#output]
            latest_iso = output_iso[1]
        end

        local meta_span = {}

        if author then
            table.insert(meta_span, "by ")
            table.insert(meta_span, pandoc.RawInline("html", "<hcard class=p-author>"))
            table.insert(meta_span, pandoc.utils.stringify(author))
            table.insert(meta_span, pandoc.RawInline("html", "</hcard>"))
        end

        if #meta_span ~= 0 then
            table.insert(meta_span, pandoc.Str(" ⬩ "))
        end
        table.insert(meta_span, pandoc.RawInline("html", "<time class=dt-published datetime=\"" .. earliest_iso .. "\">"))
        table.insert(meta_span, earliest)
        table.insert(meta_span, pandoc.RawInline("html", "</time>"))

        if earliest ~= latest then
            table.insert(meta_span, pandoc.Str(" ⬩ "))
            table.insert(meta_span, "updated ")
            table.insert(meta_span, pandoc.RawInline("html", "<time class=dt-updated datetime=\"" .. latest_iso .. "\">"))
            table.insert(meta_span, latest)
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
