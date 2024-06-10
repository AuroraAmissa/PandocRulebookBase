import os.path
import tomllib
import tomli_w

def merge(base, new):
    out = {}
    keys = set(base.keys() | new.keys())

    for key in keys:
        if key in base and key in new:
            if type(base[key]) == dict or type(new[key]) == dict:
                assert type(base[key]) == dict and type(new[key]) == dict
                out[key] = merge(base[key], new[key])
            else:
                out[key] = new[key]
        elif key in base:
            out[key] = base[key]
        else:
            out[key] = new[key]

    return out


base = tomllib.loads(open("PandocRulebookBase/soupault_base.toml").read())

meta = tomllib.loads(open("templates/meta.toml").read())
base["widgets"]["page-title"]["default"] = meta["config"]["title"]
base["widgets"]["page-title"]["append"] = " | " + meta["config"]["title"]
base["custom_options"] = { "site_title": meta["config"]["title"] }

os.mkdir("build/soupault/site")

if "website_mode" in meta["config"] and meta["config"]["website_mode"]:
    open("build/extract/website_mode", "w").write("-")
    del base["templates"]["redirect"]
    base["settings"]["clean_urls"] = True
    base["settings"]["default_template_file"] = "PandocRulebookBase/templates/main_website.html"
    if "toc_allowed" in meta["config"] and len(meta["config"]["toc_allowed"]) > 0:
        base["widgets"]["table-of-contents"]["section"] = meta["config"]["toc_allowed"]
        base["widgets"]["table-of-contents"]["include_subsections"] = True
        base["widgets"]["page_no_toc"]["exclude_section"] = meta["config"]["toc_allowed"]
        base["widgets"]["page_no_toc"]["include_subsections"] = True
    else:
        base["widgets"]["table-of-contents"]["selector"] = "#run-never"
else:
    web_path = meta["config"]["path"]

    os.mkdir(f"build/soupault/site/{web_path}")

    if "entry" in meta:
        name = meta["entry"]["name"]
        path = meta["entry"]["path"]
        contents = f'<meta http-equiv="refresh" content="0; URL={path}"/>'
        open(f"build/soupault/site/{name}.html", "w").write(contents)

        web_entry = meta["entry"]["name"]
        web_entry_path = meta["entry"]["path"]
    else:
        web_entry = "unknown"
        web_entry_path = "unknown"

    readme_message = f"""
    Please use the <{web_entry}.html> file in the archive root instead!
    The file names here are more organized for easy development rather than being easy to find things.
    If you really insist, the title page can be found at <{web_entry_path}>.
    """

    open(f"build/soupault/site/{web_path}/!! PLEASE README !!.txt", "w").write(readme_message)
    open("build/extract/web_path", "w").write(web_path)

    del base["widgets"]["page_no_toc"]

if "soupault" in meta:
    merged = merge(base, meta["soupault"])
else:
    merged = base

open("build/soupault/soupault.toml", "w").write(tomli_w.dumps(merged))
