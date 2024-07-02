import glob
import json
import os.path
import time
import re

import common

def prepare_run(config, soupault_config):
    resource_root = config["config"]["resource_root"]

    # Prepare the heading data map
    files = {}
    for file in glob.glob("build/sources/soupault/site/**/*.md", recursive=True):
        contents = open(file, "r").read()

        title = None
        for line in contents.split("\n"):
            if line.startswith("# "):
                title = line[2:]
                title = title.split("{")[0].strip()
                break

        if title:
            full_path = common.strip_path_prefix(file, "build/sources/soupault/site/")
            full_path = full_path.replace(".md", "")
            if "clean_urls" in soupault_config["settings"] and soupault_config["settings"]["clean_urls"]:
                full_path = full_path.replace("_content/", "").replace("/index", "")
            elif not full_path.endswith(".html"):
                full_path += ".html"

            files[title.lower()] = full_path
            files[title.lower().replace(" ", "%20")] = full_path
    open("build/run/pages.json", "w").write(json.dumps(files))

    # Prepares the alt-text data map
    alt_list = {}
    if "alt" in config:
        for tag, value in config["alt"].items():
            alt_list[tag] = value.replace("((", "").replace("))", "")
            alt_list[f"{tag}_ny"] = re.sub(r"\(\(.+\)\)", "", value)
    open("build/run/alt.json", "w").write(json.dumps(alt_list))

    # Prepares the stylesheet data
    style_list = {}
    resource_paths_list = {}
    re_list = []

    if "styles" in config:
        for key in config["styles"]:
            re_list.append(("|".join(config["styles"][key]), key))
    for file in glob.glob("build/sources/soupault/site/**", recursive=True):
        if not os.path.isfile(file):
            continue

        sheet_name = "style.css"
        for data in re_list:
            regex, sheet = data
            if re.search(regex, file):
                sheet_name = f"style_{sheet}.css"

        ts=int(time.time())
        if "clean_urls" in soupault_config["settings"] and soupault_config["settings"]["clean_urls"]:
            css_path = f"/{resource_root}/styles/{sheet_name}?ts={ts}"
            resource_path = f"/{resource_root}/"
        else:
            css_path = common.path_relative_to(
                "build/sources/soupault/site/",
                file,
                f"build/sources/soupault/site/{resource_root}/styles/{sheet_name}?ts={ts}"
            )
            resource_path = common.path_relative_to(
                "build/sources/soupault/site/",
                file,
                f"build/sources/soupault/site/{resource_root}/"
            )

        style_list[file] = css_path
        resource_paths_list[file] = resource_path

    open("build/run/styles.json", "w").write(json.dumps(style_list))
    open("build/run/resource_paths.json", "w").write(json.dumps(resource_paths_list))