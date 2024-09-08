#! /usr/bin/env python3

# Syspath manipulation
__import__("sys").path.append(__import__("os").path.abspath('PandocRulebookBase/scripts/py'))

# Proper imports
import glob
import json
import os
import shutil
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
os.makedirs("build/pdf/out")

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
                    pdfauthor={{{config["config"]["author"]}}},
                    pdfdisplaydoctitle]{{hyperref}}
    """)

def run_result(args):
    result = common.run(args, capture = True).decode("utf-8").strip()
    return result


with open("build/pdf/tex/_generated_buildinfo.tex", "w") as fd:
    version = run_result(["git", "describe", "--match=^v", "--always", "--dirty=-*"])
    revision = run_result(["git", "describe", "--match=x^", "--always", "--dirty=-*"])
    commit_time = run_result(["git", "log", "-1", "--date=short", "--pretty=format:%cd"])
    git_hash = run_result(["git", "log", "-1", "--pretty=format:%H"])

    is_draft = r"\newcommand\buildIsDraft\relax"
    if os.getenv("DO_RELEASE"):
        is_draft = ""

    is_playtest = ""
    if os.getenv("DO_PLAYTEST"):
        is_playtest = r"\newcommand\buildIsPlaytest\relax"

    is_ci_release = ""
    if os.getenv("DO_CI_RELEASE"):
        is_ci_release = r"\newcommand\buildIsCiRelease\relax"

    fd.write(rf"""
        \newcommand\gitVersion{{{version}}}
        \newcommand\gitRevision{{{revision}}}
        \newcommand\gitCommitTime{{{commit_time}}}
        \newcommand\gitCommitHash{{{git_hash}}}
        {is_draft}
        {is_playtest}
        {is_ci_release}
    """)

with open("build/pdf/tex/_generated_fonts.tex", "w") as fd:
    fd.write(tex_fonts.generate_tex_fonts(config))

for path in glob.glob("build/pdf/tex/images/*"):
    if os.path.isfile(path):
        print(f"Converting {path} to JPEG 2000...")
        root = os.path.splitext(path)[0]
        common.run(["magick", "-define", "jp2:quality=60", path, f"{root}.jp2"])

# Run latex
os.chdir("build/pdf/tex")
books = config["pdf"]["books"]
for book_name in books:
    common.run([
        "latexmk", "-interaction=nonstopmode", "-pdflatex=lualatex",
        "-pdf", f"{book_name}.tex"
    ])
    print("Compressing PDF...")
    common.run([
        "qpdf", "--linearize", "--object-streams=generate", "--newline-before-endstream",
        "--decode-level=generalized", "--recompress-flate", "--compression-level=9",
        f"{book_name}.pdf", f"../out/{books[book_name]}.pdf",
    ])
