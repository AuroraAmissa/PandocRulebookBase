-- Image transcoding plugin for Soupault,
-- written by Tiffany Bennett <https://tiffnix.com>
--
-- This work is licensed under CC BY-SA 4.0
-- <https://creativecommons.org/licenses/by-sa/4.0/>
--
-- Finds `<img>` elements and transcodes them. Also wraps them in a
-- `<picture>` element with multiple alternate formats for browsers
-- which support them, specifically JPEG-XL, AVIF, and WebP.
--
-- The logic for deciding how to do transcoding is located at the bottom
-- of the file. You will most likely need to configure it based on your
-- own needs.

-- Modifications by Rimi:
-- * Removed code for banner processing and favicon processing.
-- * General customizations for my setup.

resource_paths = JSON.from_string(Sys.read_file("build/run/resource_paths.json"))

src_images_base = soupault_config["custom_options"]["resource_root"] .. "/images/"
images_base_strsub = String.length(src_images_base) + 1
target_images_uri = resource_paths[page_file] .. "images/"

if not global_data["images_cache"] then
    global_data["images_cache"] = {}
end

-- Resizes an image using ImageMagick.
-- @param input  Path to process, relative to the site dir.
--               Example: `/images/friend-shaped.jpg`
-- @param output Path to write to, relative to the build dir.
--               Example: `/thumbnails/friend-shaped.jpg`
-- @param cmd    Parameters to pass to ImageMagick.
--               Example: `-resize 640x480`
-- @return       The image width and height in pixels.
function resize(input, output, cmd)
    local input_path = Sys.join_path(site_dir, input)
    if not Sys.is_file(input_path) then
        input_path = Sys.join_path(build_dir, input)
    end
    local output_path = Sys.join_path(build_dir, Sys.join_path(src_images_base, output))
    local output_dir = Sys.dirname(output_path)
    Sys.mkdir(output_dir)
    if Sys.is_file(output_path) then
        local input_mt = Sys.get_file_modification_time(input_path)
        local output_mt = Sys.get_file_modification_time(output_path)
        if output_mt > input_mt then
            if global_data["images_cache"][output_path] then
                local width = global_data["images_cache"][output_path]["width"]
                local height = global_data["images_cache"][output_path]["height"]
                return width, height
            else
                -- No need to regenerate this file if it hasn't been
                -- updated. But we still need to return the size in pixels.
                local command = format("magick identify -format %%w:%%h \"%s\"", output_path)
                local output = Sys.get_program_output(command)
                local colon = strfind(output, ":")
                local width = strsub(output, 1, colon - 1)
                local height = strsub(output, colon + 1)

                global_data["images_cache"][output_path] = {}
                global_data["images_cache"][output_path]["width"] = width
                global_data["images_cache"][output_path]["height"] = height

                return width, height
            end
        end
    end
    local command = format(
            "magick \"%s\" %s -strip -format %%w:%%h -identify \"%s\"",
            input_path,
            cmd,
            output_path
    )
    Log.info("Running " .. command)
    local output = Sys.get_program_output(command)
    local colon = strfind(output, ":")
    local width = strsub(output, 1, colon - 1)
    local height = strsub(output, colon + 1)

    local png_opt = config["png_optimizer"]
    if png_opt and Sys.has_extension(output_path, "png") then
        local command = format(png_opt, output_path)
        Log.info("Optimizing png using " .. command)
        Sys.run_program(command)
    end

    return width, height
end

-- Creates a `<source>` element for use inside of the `<picture>`.
-- Each source has a single file and MIME type.
-- @param src    Source image to process
-- @param suffix The folder to put the output image in
--               Example: `/thumbnail/`
-- @param cmd    Parameters to pass to ImageMagick
-- @param parent Parent `<picture>` element to prepend to
-- @param hidpi  ImageMagick params for @2x version.
--               Won't be generated if nil.
-- @param ext    File extension to generate (`.jpg`, `.avif`)
-- @param mime   Corresponding MIME type (`image/jpg`)
function build_source(src, suffix, cmd, parent, hidpi, ext, mime)
    local base_src = strsub(src, images_base_strsub)
    local base = Sys.strip_extensions(base_src) .. ext
    local new_src = suffix .. base
    resize(src, new_src, cmd)
    local srcset
    if hidpi then
        local src_2x = suffix .. "2x/" .. base
        resize(src, src_2x, hidpi)
        srcset = format("%s, %s 2x", target_images_uri .. new_src, target_images_uri .. src_2x)
    else
        srcset = target_images_uri .. new_src
    end
    local source = HTML.create_element("source")
    HTML.set_attribute(source, "srcset", srcset)
    HTML.set_attribute(source, "type", mime)
    HTML.prepend_child(parent, source)
end

-- Take an `<img>` element, update the src, and wrap it in a `<picture>`.
-- @param img    The `<img>` element
-- @param src    The element's src attribute
-- @param suffix Prefix to use for putting images into
--               Example: `/thumbnails/`
-- @param ext    File extension to force the `src` to, like `.jpg`.
--               Can be nil to use original format of the `<img>`.
-- @param cmd    Parameters to pass to ImageMagick
-- @param hidpi  ImageMagick params for @2x version.
--               Won't be generated if nil.
function build_images(img, src, suffix, ext, cmd, hidpi)
    local base_src = strsub(src, images_base_strsub)
    local new_src
    if ext then
        new_src = suffix .. Sys.strip_extensions(base_src) .. ext
    else
        new_src = suffix .. base_src
    end

    local w, h = resize(src, new_src, cmd)

    HTML.set_attribute(img, "src", target_images_uri .. new_src)
    -- It's very important to set the image width/height correctly, so
    -- that the page won't reflow when the image loads in. However, this
    -- is a pain in the butt when authoring pages, so doing it in the
    -- transcoding plugin is super convenient.
    HTML.set_attribute(img, "width", tostring(w))
    HTML.set_attribute(img, "height", tostring(h))

    local picture = HTML.create_element("picture")
    HTML.wrap(img, picture)
    build_source(src, suffix, cmd, picture, hidpi, ".webp", "image/webp")
    build_source(src, suffix, cmd, picture, hidpi, ".avif", "image/avif")
    build_source(src, suffix, cmd, picture, hidpi, ".jxl", "image/jxl")

    return picture
end

-- Small thumbnails, like in feeds.
function build_thumbnail(img, src)
    build_images(
            img,
            src,
            "thumb/",
            ".jpg",
            "-resize 320x240^ -gravity Center " .. "-extent 320x240 -quality 80%"
    )
end

-- Tiny profile pictures for mf2 h-cards. Small icons like
-- these are where having an @2x version makes the biggest
-- impact.
function build_pfp(img, src)
    build_images(
            img,
            src,
            "profile-pic/",
            nil,
            "-resize 32x32 -quality 80%",
            "-resize 64x64 -quality 80%"
    )
end

-- General images that appear inside of the article. These
-- are expected to take up the full page width.
function build_preview(img, src)
    local picture = build_images(img, src, "preview/", nil, "-resize 640x480 -quality 80%")
    -- Make a nice link to the full res version. Not trying to
    -- be bandwidth gremlins or anything, just want to make
    -- pages faster to load.
    local link = HTML.create_element("a")
    HTML.set_attribute(link, "href", src)
    local title = "Click for original resolution"
    HTML.set_attribute(link, "title", title)
    HTML.wrap(picture, link)
end

-- Processes all img tags on the page. Main entry point as a plugin.
function process_page(page)
    local imgs = HTML.select(page, "img")
    local index = 1
    while imgs[index] do
        local img = imgs[index]
        local src = HTML.get_attribute(img, "src")
        if String.starts_with(src, src_images_base) then
            if HTML.matches_selector(page, img, "picture>img") then
                -- this was already processed, skip it
            elseif HTML.has_class(img, "thumb") then
                build_thumbnail(img, src)
            elseif HTML.matches_selector(page, img, ".h-card img") then
                build_pfp(img, src)
            elseif HTML.matches_selector(page, img, "article img") then
                local input_path = Sys.join_path(site_dir, src)
                local command = format("magick identify -format %%w:%%h %s", input_path)
                local output = Sys.get_program_output(command)
                build_preview(img, src)
            end
        end

        index = index + 1
    end
end

process_page(page)
