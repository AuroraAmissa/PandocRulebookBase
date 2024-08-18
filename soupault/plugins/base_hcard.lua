local resource_paths = JSON.from_string(Sys.read_file("build/run/resource_paths.json"))

image_src = soupault_config["custom_options"]["resource_root"] .. "/images/"
target_images_uri = resource_paths[page_file] .. "images/"

local function add_rel(e, new)
    if e then
        local rel_name = HTML.get_attribute(e, "rel")
        if rel_name then
            HTML.set_attribute(e, "rel", rel_name .. " " .. new)
        else
            HTML.set_attribute(e, "rel", new)
        end
    end
end

for _, e in HTML.select(page, "hcard") do
    local user = HTML.inner_text(e)
    local hcard = HTML.parse(Sys.read_file("PandocRulebookBase/soupault/template/hcard/" .. user .. ".html"))
    hcard = HTML.select_one(hcard, ".h-card")

    assert(hcard, "Could not find H-card?")
    local photo_tag = HTML.select_one(hcard, "img.u-photo")

    if photo_tag then
        local pfp = HTML.get_attribute(photo_tag, "src")
        local pfp_source = "PandocRulebookBase/soupault/template/hcard/" .. pfp
        local pfp_target = Sys.join_path(build_dir, Sys.join_path(image_src, pfp))

        if not Sys.is_file(pfp_target) then
            Sys.mkdir(Sys.dirname(pfp_target))
            Sys.write_file(pfp_target, Sys.read_file(pfp_source))
        end

        HTML.set_attribute(photo_tag, "src", target_images_uri .. pfp)
    end

    if HTML.get_attribute(e, "aria-hidden") then
        HTML.set_attribute(hcard, "aria-hidden", HTML.get_attribute(e, "aria-hidden") or unreachable())
    end
    if HTML.has_class(e, "p-author") then
        HTML.add_class(hcard, "p-author")
        add_rel(HTML.select_one(hcard, ".p-name"), "author")
    end
    if HTML.has_class(e, "h-card-hidden") then
        HTML.add_class(hcard, "h-card-hidden")
    end
    if HTML.has_class(e, "rel-me") then
        add_rel(HTML.select_one(hcard, ".u-url"), "me")
    end

    HTML.replace_element(e, hcard)
end
