def rewrite_markdown(source: str) -> str:
    lines = []
    for line in source.splitlines():
        sline = line.strip()
        if sline.startswith("@![") and sline.endswith("]"):
            with open(sline[3:-1]) as fd:
                lines += rewrite_markdown(fd.read()).splitlines()
        else:
            lines.append(line)
    return "\n".join(lines)
