from bs4 import BeautifulSoup
from glob import glob
import subprocess
import tomllib

classify_info = {
    "main": {
        "name": ['body'],
        "class": ['ability-head'],
    },
    "title": {
        "name": ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'],
        "class": ['nav-header', 'h0'],
    },
    "code": {
        "name": ["code"],
        "class": ["highlight"],
    },
    "symbol": {
        "name": [],
        "class": ['a-left', 'a-right', 'symbol', 'sy', 'section'],
    },
    "zh": {
        "name": [],
        "class": ["zh"],
    },
    "hidden": {
        "name": ["style", "script", "head", "title", "meta", "[document]"],
        "class": [],
    },
}
classifications = set(classify_info.keys())
classifications.remove("hidden")
classifications = sorted(list(classifications))

meta = tomllib.loads(open("templates/meta.toml").read())
if "website_mode" in meta["config"] and meta["config"]["website_mode"]:
    root_path = "build/web/static"
    img_path = "img_XXXX"
else:
    root_path = meta["config"]["path"]
    root_path = f"build/web/{root_path}"
    img_path = "img"


def classify_element(element):
    for key in classify_info:
        value = classify_info[key]
        if element.name in value["name"]:
            return key
        if "class" in element.attrs:
            for cl in value["class"]:
                if cl in element.attrs["class"]:
                    return key
    return classify_element(element.parent)


def text_from_html(body: str, filter_with: str):
    soup = BeautifulSoup(body, 'html.parser')
    texts = soup.findAll(string=True)
    visible_texts = filter(lambda x: classify_element(x.parent) == filter_with, texts)
    return u" ".join(filter(lambda x: x != "", (t.strip() for t in visible_texts))).replace("\n", " ")


def text_from_css(css: str):
    lines = []
    for line in css.split("\n"):
        line = line.strip()
        if line.startswith("content: \""):
            line = line.replace("content: \"", "")
            if line.endswith("\";"):
                line = line.replace("\";", "")
            lines.append(line)
    return u" ".join(lines)


def glyphs(t: str):
    return repr("".join(sorted(list(set(t)))))


text_classes = {}
for c in classifications:
    text_classes[c] = ""
for page in glob("build/web/**/*.html", recursive=True):
    html = open(page).read()
    for c in classifications:
        text_classes[c] += text_from_html(html, c) + "\n\n"
text_classes["symbol"] += text_from_css(open("build/extract/style.css").read()) + "\n\n"

for c in classifications:
    open(f"build/extract/text_{c}.txt", "w").write(text_classes[c])
    print(f"Glyphs for '{c}': {glyphs(text_classes[c])}")


font_defs = {}
def push_font(name):
    if not name in meta["fonts"]:
        return

    font_file = meta["fonts"][name]
    if not font_file in font_defs:
        font_defs[font_file] = set([])

    font_defs[font_file].add(f"--subset-from=build/extract/text_{name}.txt")

    fallback_attr = f"{name}_fallback"
    if fallback_attr in meta["fonts"]:
        for fallback in meta["fonts"][fallback_attr]:
            font_defs[font_file].add(f"--subset-from=build/extract/text_{fallback}.txt")

all_style_scss = """
// Autogenerated from Python
@use 'style';
"""

def make_font_cmdline(font_file):
    name = hex(abs(hash(font_file)))
    subset_args = list(font_defs[font_file])
    subset_args.sort()

    global all_style_scss
    all_style_scss += f"@use 'wf_{name}';\n"

    return [
        "PandocRulebookBase/support/mkwebfont.sh", "-v", "--splitter=none",
        "--store", f"{root_path}/webfonts", "--store-uri", "../webfonts/",
        font_file, "-o", f"{root_path}/{img_path}/wf_{name}.scss",
    ] + subset_args


for font in classifications:
    push_font(font)


cmdlines = [make_font_cmdline(x) for x in font_defs.keys()]
for cmdline in cmdlines:
    print(cmdline)
proc = subprocess.run(["PandocRulebookBase/support/mkwebfont.sh", "--help"], capture_output = True)
for cmd in [subprocess.Popen(cmd) for cmd in cmdlines]:
    cmd.wait()
    if cmd.returncode != 0:
        raise "Bad return!"

open(f"{root_path}/{img_path}/all_style.scss", "w").write(all_style_scss)
