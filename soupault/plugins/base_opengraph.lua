-- OpenGraph metadata plugin for Soupault,
-- written by Tiffany Bennett <https://tiffnix.com>
--
-- This work is licensed under CC BY-SA 4.0
-- <https://creativecommons.org/licenses/by-sa/4.0/>
--
-- If you have mf2 metadata most of this should just magically work.
-- If you don't have mf2 metadata, I suggest you add it, because it'll
-- be just as much work as trying to hack around its absence.
--
-- Rips the <h1> element for the og:title.
-- Should be good enough in most cases.
--
-- Assumes that everything that isn't an index.md page is an article.
-- This may or may not work for your usage.
--
-- Pulls `site_title` from the `[custom_options]` section for the
-- og:site_name field.

local site_title = soupault_config["custom_options"]["site_title"]

-- Creates a `<meta>` tag and puts it into `<head>`.
local function add_meta(property, content)
    if not content then
        return
    end

    content = string.trim(content)
    content = Regex.replace_all(content, "\\s+", " ")

    local head = HTML.select_one(page, "head")
    if not head then
        Log.error("No <head> element found")
    end

    local existing = HTML.select_one(head, 'meta[property="' .. property .. '"]')
    if existing then
        return
    end

    local meta = HTML.create_element("meta")
    HTML.set_attribute(meta, "content", content)
    HTML.set_attribute(meta, "property", property)
    HTML.append_child(head, meta)
end

-- required metadata:
local type = "article"
if not HTML.select_one(page, "h1") then
    type = "website"
end
add_meta("og:type", type)

local title_elt = HTML.select_one(page, "h1")
local title = title_elt and HTML.inner_text(title_elt)
add_meta("og:title", title)

local image_elt = HTML.select_one(page, ".e-content img")
local image = image_elt and HTML.get_attribute(image_elt, "src")
local image_alt = image_elt and HTML.get_attribute(image_elt, "alt")
add_meta("og:image", image)
add_meta("og:image:alt", image_alt)

local uid_elt = HTML.select_one(page, "span.u-uid")
local uid = uid_elt and HTML.inner_text(uid_elt)
add_meta("og:url", uid)

-- optional metadata:
local desc_elt = HTML.select_one(page, "p.p-summary")
local desc = desc_elt and HTML.inner_text(desc_elt)
add_meta("og:description", desc)

add_meta("og:site_name", site_title)

-- article metadata:
if type == "article" then
    local published_elt = HTML.select_one(page, "time.dt-published")
    local published = published_elt
            and HTML.get_attribute(published_elt, "datetime")
    add_meta("article:published_time", published)

    local updated_elt = HTML.select_one(page, "time.dt-updated")
    local updated = updated_elt and HTML.get_attribute(updated_elt, "datetime")
    add_meta("article:modified_time", updated)

    local author_elt = HTML.select_one(page, ".h-card .p-name")
    local author = author_elt and HTML.inner_text(author_elt)
    add_meta("article:author", author)

    local section_elt = HTML.select_one(page, "#post-section")
    local section = section_elt and HTML.inner_text(section_elt)
    add_meta("article:section", section)
end