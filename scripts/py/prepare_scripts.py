#!/usr/bin/env python3

# Syspath manipulation
__import__("sys").path.append(__import__("os").path.abspath('PandocRulebookBase/scripts/py'))

# Proper imports
import tomllib

# Dump script data to disk
config = tomllib.loads(open("template/meta.toml").read())

title = config["config"]["title"]

with open("build/PARAM_TITLE", "w") as fd:
    fd.write(title)

with open("build/PARAM_ARCHIVE_TITLE", "w") as fd:
    fd.write(title.replace(" ", ""))
