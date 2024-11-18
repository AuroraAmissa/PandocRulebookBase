#! /usr/bin/env python3

# Syspath manipulation
__import__("sys").path.append(__import__("os").path.abspath('PandocRulebookBase/scripts/py'))

# Proper imports
import glob
import json
import os
import shutil
import tomllib
import tomli_w

import common
import custom_markdown
import prepare_run

# Setup
config = tomllib.loads(open("template/meta.toml").read())

resource_root = config["config"]["resource_root"]

# Prepares the necessary directories
common.del_contents("build/web")
common.recreate_dir("build/sources")
common.recreate_dir("build/run")

# Create CSS sources
os.makedirs("build/sources/css")
os.makedirs("build/sources/css/PandocRulebookBase")

for path in glob.glob("template/web/styles/**/*.scss", recursive=True):
    common.copy_file_to("template/web/styles/", path, "build/sources/css")

for path in glob.glob("PandocRulebookBase/**/*.scss", recursive=True):
    common.copy_file_to("PandocRulebookBase/", path, "build/sources/css/PandocRulebookBase")

# Build styles directory
os.makedirs(f"build/sources/soupault/site/{resource_root}/styles")
for path in glob.glob("build/sources/css/style*.scss"):
    fragment = common.strip_path_prefix(path, "build/sources/css/")
    target_name = fragment.replace(".scss", ".css")
    common.run([
        "dart-sass",
        "-c", "--no-source-map",
        f"{path}:build/sources/soupault/site/{resource_root}/styles/{target_name}",
    ])

for path in glob.glob("template/web/styles/**", recursive=True):
    if not path.endswith(".scss"):
        common.copy_file_to("template/web/styles/", path, f"build/sources/soupault/site/{resource_root}/styles")

# Build soupault sources directory
has_entry = False
entry_name = "unknown"
entry_path = "unknown"

if "entry" in config:
    has_entry = True
    entry_name = config["entry"]["name"]
    entry_path = config["entry"]["path"]

pls_readme_name = "!! PLEASE README !!.txt"
pls_readme_contents = f"""
Please use the <{entry_name}.html> file in the archive root instead!
The file names here are more organized for easy development rather than being easy to find things.
If you really insist, the title page can be found at <{entry_path}>.
"""

origins = {}
short_paths = {}
if os.path.exists("site"):
    for path in glob.glob("site/**", recursive=True):
        target = common.copy_file_to("site/", path, "build/sources/soupault/site")
        origins[target] = path
        short_paths[target] = common.strip_path_prefix(path, "site/")
if os.path.exists("content"):
    os.makedirs(f"build/sources/soupault/site/{resource_root}", exist_ok=True)
    for path in glob.glob("content/**", recursive=True):
        target = common.copy_file_to("content/", path, f"build/sources/soupault/site/{resource_root}")
        origins[target] = path
        short_paths[target] = resource_root + "/" + common.strip_path_prefix(path, "content/")
    if has_entry:
        open(f"build/sources/soupault/site/{resource_root}/{pls_readme_name}", "w").write(pls_readme_contents)
for path in glob.glob("build/sources/soupault/site/**/*.md", recursive=True):
    with open(path) as fd:
        data = fd.read()
    rewritten = custom_markdown.rewrite_markdown(data)
    if rewritten != data:
        with open(path, "w") as fd:
            fd.write(rewritten)
for path in glob.glob("build/sources/soupault/site/**/include/**/*.md", recursive=True):
    os.remove(path)
if has_entry:
    contents = f'<meta http-equiv="refresh" content="0; URL={resource_root}/{entry_path}"/>'
    open(f"build/sources/soupault/site/{entry_name}.html", "w").write(contents)
open("build/run/origins.json", "w").write(json.dumps(origins))
open("build/run/short_paths.json", "w").write(json.dumps(short_paths))

# Build soupault configuration
soupault_cfg = tomllib.loads(open("PandocRulebookBase/soupault/soupault_base.toml").read())

soupault_cfg["widgets"]["page-title"]["default"] = config["config"]["title"]
soupault_cfg["widgets"]["page-title"]["append"] = " | " + config["config"]["title"]
soupault_cfg["custom_options"]["resource_root"] = resource_root
soupault_cfg["custom_options"]["site_title"] = config["config"]["title"]

if "modified_mode" in config["config"]:
    soupault_cfg["custom_options"]["modified_mode"] = config["config"]["modified_mode"]
else:
    soupault_cfg["custom_options"]["modified_mode"] = "regular"

if "nonav" in config["config"] and len(config["config"]["nonav"]) > 0:
    soupault_cfg["templates"]["nonav"]["path_regex"] = "|".join(config["config"]["nonav"])
else:
    soupault_cfg["templates"]["nonav"]["path_regex"] = "x^"

if "toc_allowed" in config["config"]:
    if len(config["config"]["toc_allowed"]) > 0:
        soupault_cfg["widgets"]["table-of-contents"]["path_regex"] = "|".join(config["config"]["toc_allowed"])
    else:
        soupault_cfg["widgets"]["table-of-contents"]["path_regex"] = "x^"
else:
    del soupault_cfg["widgets"]["website_no-toc-format"]

if not has_entry:
    del soupault_cfg["templates"]["redirect"]

if "languages" in config:
    for language in config["languages"]:
        soupault_cfg["widgets"][f"mark-{language}"] = {
            "widget": "base_mark-lang",
            "lang": language,
            "path_regex": "|".join(config["languages"][language]),
        }

if "soupault" in config:
    soupault_cfg = common.merge_config(soupault_cfg, config["soupault"])

prepare_run.prepare_run(config, soupault_cfg)

open("build/sources/soupault/soupault.toml", "w").write(tomli_w.dumps(soupault_cfg))
open("build/run/soupault.json", "w").write(json.dumps(soupault_cfg))

# Run Soupault
common.run([
    "PandocRulebookBase/scripts/sh/tool_crabsoup.sh",
    "build", "--config", "build/sources/soupault/soupault.toml",
])

# Copy extra resources
for path in glob.glob("template/web/static/**", recursive=True, include_hidden=True):
    common.copy_file_to("template/web/static/", path, "build/run/web")

# Build webfonts
shutil.copytree("build/run/web", "build/run/web_fonts")
common.run([
    "PandocRulebookBase/scripts/sh/tool_mkwebfont.sh",
    "--write-to-webroot", "--subset",
    "--store", f"build/run/web_fonts/{resource_root}/webfonts",
    "--webroot", "build/run/web_fonts", "--splitter", "none",
])

# Minify HTML
for file in glob.glob("build/run/web_fonts/**", recursive=True):
    suffix = common.strip_path_prefix(file, "build/run/web_fonts/")
    target = f"build/web/{suffix}"
    if os.path.isfile(file):
        if file.endswith(".html") or file.endswith(".css"):
            common.run(["minify", "-v", file, "-o", target])
        else:
            common.create_parent(target)
            shutil.copyfile(file, target)

# Check links
common.run(["lychee", "--offline", "build/web/"])
