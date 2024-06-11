import glob
import json
import re
import tomllib

meta_toml = tomllib.loads(open("templates/meta.toml").read())
is_website = "website_mode" in meta_toml["config"] and meta_toml["config"]["website_mode"]

files = {}

for file in glob.glob("content/*/*.md") + glob.glob("site/**/*.md", recursive=True):
    contents = open(file, "r").read()

    title = None
    for line in contents.split("\n"):
        if line.startswith("# "):
            title = line[2:]

    if title:
        if is_website:
            file_uri = ("/" + "/".join(file.split("/")[1:])).replace(".md", "").replace("/_content", "")
        else:
            file_uri = "../".join(file.split("/")[1:]).replace(".md", "") + ".html"
        files[title.lower()] = file_uri
        files[title.lower().replace(" ", "%20")] = file_uri

open("build/extract/pages.json", "w").write(json.dumps(files))
print(files)

alt_list = {}
if "alt" in meta_toml:
    for tag, value in meta_toml["alt"].items():
        alt_list[tag] = value.replace("((", "").replace("))", "")
        alt_list[f"{tag}_ny"] = re.sub(r"\(\(.+\)\)", "", value)
open("build/extract/alt.json", "w").write(json.dumps(alt_list))
print(alt_list)
