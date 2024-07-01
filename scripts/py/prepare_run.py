import glob
import json
import re

import common

def prepare_run(config, soupault_config):
    # Prepare the heading data map
    files = {}
    for file in glob.glob("build/sources/soupault/site/**/*.md", recursive=True):
        contents = open(file, "r").read()

        title = None
        for line in contents.split("\n"):
            if line.startswith("# "):
                title = line[2:]

        if title:
            full_path = common.strip_path_prefix(file,  "build/sources/soupault/site/")
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
