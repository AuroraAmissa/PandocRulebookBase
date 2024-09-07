#! /usr/bin/env nix-shell
#! nix-shell -i python3 --pure -p nix -p git -p git-lfs -p wget -p cacert
#! nix-shell -p pandoc -p texliveFull
#! nix-shell -p python311

# Syspath manipulation
__import__("sys").path.append(__import__("os").path.abspath('PandocRulebookBase/scripts/py'))

# Proper imports
import glob
import json
import os
import tomllib

import common
import custom_markdown
import tex_fonts

# Setup
config = tomllib.loads(open("template/meta.toml").read())

pdf = {}
if "pdf" in config:
    pdf = config["pdf"]

# Prepares the necessary directories
common.recreate_dir("build/pdf")

# Build the PDF sources
with open("build/pdf/meta.json", "w") as fd:
    fd.write(json.dumps(config))

for file in glob.glob("content/**/*.md", recursive=True):
    suffix = common.strip_path_prefix(file, "content/")

    with open(file, "r") as fd:
        md_source = custom_markdown.rewrite_markdown(fd.read())

    md_path = f"build/pdf/md/{suffix}"
    common.create_parent(md_path)
    with open(md_path, "w") as fd:
        fd.write(md_source)

    division = "section"
    if "top-level-division" in pdf:
        division = pdf["top-level-division"]
    tex_source = common.run([
        "PandocRulebookBase/scripts/sh/tool_pandoc-tex.sh", md_path,
        f"--top-level-division={division}",
    ], True).decode("utf-8")

    tex_path = f"build/pdf/tex/{suffix}".replace(".md", ".tex")
    common.create_parent(tex_path)
    with open(tex_path, "w") as fd:
        fd.write(tex_source)

for path in glob.glob("template/tex/**/*", recursive=True):
    common.copy_file_to("template/tex/", path, "build/pdf/tex/")

for path in glob.glob("PandocRulebookBase/latex/**/*.tex", recursive=True):
    common.copy_file_to("PandocRulebookBase/latex/", path, "build/pdf/tex/")

with open("build/pdf/tex/_generated_pkgs.tex", "w") as fd:
    fd.write(rf"""
        \usepackage[pdftex,
                    pdftitle={{{config["config"]["title"]}}},
                    pdfauthor={{{config["config"]["author"]}}},
                    pdfdisplaydoctitle]{{hyperref}}
    """)

with open("build/pdf/tex/_generated_fonts.tex", "w") as fd:
    fd.write(tex_fonts.generate_tex_fonts(config))

# Run latex
os.chdir("build/pdf/tex")
for file in glob.glob("book*.tex"):
    common.run(["latexmk", "-interaction=nonstopmode", "-pdflatex=lualatex", "-pdf", file])
