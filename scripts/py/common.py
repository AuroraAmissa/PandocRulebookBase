import shutil
import os

def strip_path_prefix(path, prefix):
    if not prefix.endswith("/"):
        prefix += "/"
    if path.startswith(prefix):
        return path[len(prefix):]
    else:
        raise Exception(f"Path does not start with '{prefix}'.")

def path_relative_to(root, source, target):
    if not source.startswith(root):
        raise Exception(f"Source path is not a child of '{root}'.")
    if not target.startswith(root):
        raise Exception(f"Target path is not a child of '{root}'.")

    if os.path.basename(source).startswith("index."):
        source = os.path.dirname(source)

    rela_source = source[len(root):]
    rela_target = target[len(root):]
    super_name = ""

    while not rela_target.startswith(rela_source):
        if "/" in rela_source:
            rela_source = os.path.dirname(rela_source)
        else:
            rela_source = ""
        super_name += "../"

    return super_name + rela_target[len(rela_source):]

def del_path(target):
    if os.path.isdir(target):
        shutil.rmtree(target)
    else:
        os.remove(target)

def del_contents(target):
    if os.path.exists(target):
        if not os.path.isdir("build/web"):
            os.remove("build/web")
        else:
            for path in os.listdir("build/web"):
                del_path("build/web/" + path)
    os.makedirs("build/web", exist_ok=True)

def recreate_dir(target):
    if os.path.exists(target):
        del_path(target)
    os.makedirs(target)

def create_parent(path):
    os.makedirs(os.path.dirname(path), exist_ok=True)

def copy_file_to(root, source, target):
    if not os.path.exists(source):
        raise Exception(f"'{source}' does not exist.")
    if not os.path.isfile(source):
        return

    root = os.path.abspath(root)
    source = os.path.abspath(source)
    suffix = strip_path_prefix(source, root)

    if not target.endswith("/"):
        target += "/"
    target_path = target + suffix
    create_parent(target_path)
    shutil.copyfile(source, target_path)

    return target_path

def merge_config(base, new):
    out = {}
    keys = set(base.keys() | new.keys())

    for key in keys:
        if key in base and key in new:
            if type(base[key]) == dict or type(new[key]) == dict:
                assert type(base[key]) == dict and type(new[key]) == dict
                out[key] = merge_config(base[key], new[key])
            else:
                out[key] = new[key]
        elif key in base:
            out[key] = base[key]
        else:
            out[key] = new[key]

    return out
