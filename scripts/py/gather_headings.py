import glob
import json
import re
import tomllib

files = {}

for file in glob.glob("content/*/*.md"):
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
for tag, value in tomllib.loads(open("templates/meta.toml").read())["alt"].items():
    alt_list[tag] = value.replace("((", "").replace("))", "")
    alt_list[f"{tag}_ny"] = re.sub(r"\(\(.+\)\)", "", value)
open("build/extract/alt.json", "w").write(json.dumps(alt_list))
print(alt_list)
