HTML = HTML
Table = Table
Sys = Sys
build_dir = build_dir
page = page
soupault_config = soupault_config

image_src = soupault_config["custom_options"]["image_src"]
image_uri = soupault_config["custom_options"]["image_uri"]

function add_rel(e, new)
    local rel_name = HTML.get_attribute(e, "rel")
    if rel_name then
        HTML.set_attribute(e, "rel", rel_name .. " " .. new)
    else
        HTML.set_attribute(e, "rel", new)
    end
end

function render_hcard(e)
    local user = HTML.inner_text(e)
    local hcard = HTML.parse(Sys.read_file("PandocRulebookBase/templates/hcard/" .. user .. ".html"))
    hcard = HTML.select_one(hcard, ".h-card")

    local pfp = HTML.get_attribute(HTML.select_one(hcard, "img.u-photo"), "src")
    local pfp_source = "PandocRulebookBase/templates/hcard/" .. pfp
    local pfp_target = Sys.join_path(build_dir, Sys.join_path(image_src, pfp))

    if not Sys.is_file(pfp_target) then
        Sys.mkdir(Sys.dirname(pfp_target))
        Sys.write_file(pfp_target, Sys.read_file(pfp_source))
    end

    if HTML.get_attribute(e, "aria-hidden") then
        HTML.set_attribute(hcard, "aria-hidden", HTML.get_attribute(e, "aria-hidden"))
    end
    if HTML.has_class(e, "p-author") then
        HTML.add_class(hcard, "p-author")
    end
    if HTML.has_class(e, "h-card-hidden") then
        HTML.add_class(hcard, "h-card-hidden")
    end
    if HTML.has_class(e, "rel-me") then
        add_rel(HTML.select_one(hcard, ".u-url"), "me")
    end
    if HTML.has_class(e, "rel-author") then
        add_rel(HTML.select_one(hcard, ".p-name"), "author")
    end

    HTML.set_attribute(HTML.select_one(hcard, "img.u-photo"), "src", image_src .. pfp)
    HTML.replace(e, hcard)
end

Table.iter_values(render_hcard, HTML.select(page, "hcard"))