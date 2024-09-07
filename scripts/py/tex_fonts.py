import glob
import json
import os
import re

import common

class Font(object):
    def __init__(self, string):
        split = string.split(',')
        self.name = split[0]
        self.args = {}
        self.found = False
        for arg in split[1:]:
            if "=" in arg:
                split_arg = arg.split("=")
                assert(len(split_arg) == 2)
                setattr(self, split_arg[0], split_arg[1])
                self.args[split_arg[0]] = split_arg[1]
            else:
                self.args[arg] = True

def lookup_font(font, is_bold, is_italic):
    for subfont in font:
        bold_matches = (subfont["weight"] != "Regular") == is_bold
        italic_matches = (subfont["style"] != "Regular") == is_italic

        if bold_matches and italic_matches:
            return subfont

    if is_bold and is_italic:
        return lookup_font(font, True, False)
    elif is_bold or is_italic:
        return lookup_font(font, False, False)
    else:
        raise Exception("No normal font?")

def find_font_features(name, is_bold, is_italic, font, font_obj, fallback):
    normal_weight = int(font_obj.args["Weight"]) if "Weight" in font_obj.args else 400
    bold_weight = int(font_obj.args["BoldWeight"]) if "BoldWeight" in font_obj.args else 700
    weight = normal_weight if not is_bold else bold_weight

    target_font = lookup_font(font, is_bold, is_italic)
    font_obj.found = True

    features = ""
    raw_features = ""
    if not weight >= target_font["weight_range"]["start"] or not weight <= target_font["weight_range"]["end"]:
        if target_font["weight"] == "Regular" and is_bold:
            features += "FakeBold = 1.5, "
            raw_features += "embolden=1.5;"
    elif target_font["weight_range"]["start"] != target_font["weight_range"]["end"]:
        features += f"Weight = {weight}, "
        raw_features += f"axis={{wght={weight}}};"
    if target_font["style"] == "Regular" and is_italic:
        features += "FakeSlant = 0.15, "
        raw_features += "slant=0.15;"
    if not fallback:
        features += f"RawFeature = {{fallback={name}Chain}}, "
    features = features.strip()
    raw_features = raw_features.strip(";")

    font_file = target_font["name"]

    fontspec_features = rf"""{name}Font = {font_file}, {name}Features = {{ {features} }},"""
    luaotfload_spec = rf"""[fonts/{font_file}]:mode=harf;shaper=ot;{raw_features}"""
    return fontspec_features, luaotfload_spec.strip(";")

def font_name_to_tex(font_name):
    return r"\font" + re.sub("[0-9]+", "", font_name.replace(" ", ""))

def make_tex(font_name, font, font_obj, fallback_sources):
    tex_font_name = font_name_to_tex(font_name)

    fallback = "Fallback" in font_obj.args
    regular_features, raw_regular_spec = find_font_features("Upright", False, False, font, font_obj, fallback)
    bold_features, raw_bold_spec = find_font_features("Bold", True, False, font, font_obj, fallback)
    italic_features, raw_italic_spec = find_font_features("Italic", False, True, font, font_obj, fallback)
    bold_italic_features, raw_bold_italic_spec = find_font_features("BoldItalic", True, True, font, font_obj, fallback)

    if "Fallback" in font_obj.args:
        fallback_sources["Upright"] += f"\"{raw_regular_spec}\", "
        fallback_sources["Bold"] += f"\"{raw_bold_spec}\", "
        fallback_sources["Italic"] += f"\"{raw_italic_spec}\", "
        fallback_sources["BoldItalic"] += f"\"{raw_bold_italic_spec}\", "

    return rf"""
        \defaultfontfeatures[{font_name}]{{
            Path = fonts/, Renderer = OpenType, Ligatures = TeX,
            {regular_features}
            {bold_features}
            {italic_features}
            {bold_italic_features}
        }}
        \newfontfamily{tex_font_name}{{{font_name}}}[]
    """

def make_fallbacks(fallback_sources):
    upright_spec = fallback_sources["Upright"].strip()
    bold_spec = fallback_sources["Bold"].strip()
    italic_spec = fallback_sources["Italic"].strip()
    bold_italic_spec = fallback_sources["BoldItalic"].strip()
    return rf"""
        \begin{{luacode}}
            luaotfload.add_fallback("UprightChain", {{ {upright_spec} }})
            luaotfload.add_fallback("BoldChain", {{ {bold_spec} }})
            luaotfload.add_fallback("ItalicChain", {{ {italic_spec} }})
            luaotfload.add_fallback("BoldItalicChain", {{ {bold_italic_spec} }})
        \end{{luacode}}
    """

def generate_tex_fonts(config):
    fonts = []
    if "pdf" in config and "fonts" in config["pdf"]:
        for font in config["pdf"]["fonts"]:
            print(font)
            fonts.append(Font(font))

    if len(list(filter(lambda x: "Main" in x.args, fonts))) == 0:
        fonts.append(Font("Noto Sans,Main"))
    if len(list(filter(lambda x: "Monospace" in x.args, fonts))) == 0:
        fonts.append(Font("Noto Sans Mono,Monospace"))
    if len(list(filter(lambda x: "Title" in x.args, fonts))) == 0:
        fonts.append(Font("Rounded MPLUS 1c,Title"))

    assert(len(list(filter(lambda x: "Main" in x.args, fonts))) == 1)
    assert(len(list(filter(lambda x: "Monospace" in x.args, fonts))) == 1)
    assert(len(list(filter(lambda x: "Title" in x.args, fonts))) == 1)

    fallback_fonts = list(filter(lambda x: "Fallback" in x.args, fonts))
    if len(fallback_fonts) > 0:
        fallback_fonts[-1].args[",LastFallback"] = True
    fonts = fallback_fonts + list(filter(lambda x: not "Fallback" in x.args, fonts))

    args = []
    for font in fonts:
        if not "Provided" in font.args:
            args.append("--gfont")
            args.append(font.name)
    for font in glob.glob("template/fonts/**/*.ttf", recursive=True):
        if os.path.isfile(font):
            args.append(font)

    result = common.run(
        ["PandocRulebookBase/scripts/sh/tool_mkwebfont.sh"] + args + ["--dump-fonts", "build/pdf/tex/fonts/"],
        capture=True
    )
    faces = json.loads(result)["font_faces"]

    ordering = []
    for font in fonts:
        if font.name in faces:
            ordering.append(font.name)
    for face in sorted(faces.keys()):
        if not face in ordering:
            ordering.append(face)

    tex = ""
    fallback_sources = {
        "Upright": "",
        "Bold": "",
        "Italic": "",
        "BoldItalic": "",
    }
    for font_name in ordering:
        font = faces[font_name]
        filtered = list(filter(lambda x: x.name.lower() == font_name.lower(), fonts))
        font_obj = filtered[0] if len(filtered) > 0 else Font(font_name)
        tex += make_tex(font_name, font, font_obj, fallback_sources)

        if ",LastFallback" in font_obj.args:
            tex += make_fallbacks(fallback_sources)
    tex += "\n"

    for font in fonts:
        if not font.found:
            if "Alternative" in font.args:
                alternative = font.args["Alternative"]
                tex += f"\\newcommand{font_name_to_tex(font.name)}{font_name_to_tex(alternative)}"
            else:
                raise Exception(f"Font not found: {font.name}")
        if "Main" in font.args:
            if "Alternative" in font.args:
                raise Exception("Cannot use an alternative for Main!")
            tex += f"\\setmainfont{{{font.name}}}[]\n"
            tex += f"\\setsansfont{{{font.name}}}[]\n"
        if "Monospace" in font.args:
            if "Alternative" in font.args:
                raise Exception("Cannot use a alternative for Monospace!")
            tex += f"\\setmonofont{{{font.name}}}[]\n"
        if "Title" in font.args:
            tex += f"\\newcommand\\defaultTitleFont{font_name_to_tex(font.name)}\n"

    tex = tex.replace("\n        ", "\n    ").replace("\n    ", "\n")
    tex = tex.replace(", }", " }").replace("{  }", "{}").strip() + "\n"

    return tex