import glob
import json
import re
import tomllib

files = {}

for file in glob.glob("content/*/*.md") + glob.glob("site/**/*.md", recursive=True):
    contents = open(file, "r").read()

    title = None
    for line in contents.split("\n"):
        if line.startswith("# "):
            title = line[2:]

    if title:
        files[title.lower()] = "/".join(file.split("/")[-2:])
        files[title.lower().replace(" ", "%20")] = "/".join(file.split("/")[-2:])

open("build/extract/pages.json", "w").write(json.dumps(files))
print(files)

alt_list = {}
meta_toml = tomllib.loads(open("templates/meta.toml").read())
if "alt" in meta_toml:
    for tag, value in meta_toml["alt"].items():
        alt_list[tag] = value.replace("((", "").replace("))", "")
        alt_list[f"{tag}_ny"] = re.sub(r"\(\(.+\)\)", "", value)
open("build/extract/alt.json", "w").write(json.dumps(alt_list))
print(alt_list)
