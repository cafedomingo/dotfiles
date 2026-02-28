#!/usr/bin/env python3
"""
Theme generator — reads a universal YAML theme definition and produces
config files for terminals, editors, and IDEs.

Usage:
    python generate.py electric-ink.yaml --target iterm2
    python generate.py solar-flare.yaml --target ghostty
    python generate.py solar-flare.yaml --target all

Supported targets:
    iterm2      — iTerm2 .itermcolors (XML plist)
    ghostty     — Ghostty config fragment
    alacritty   — Alacritty TOML theme
    kitty       — Kitty terminal config
    wezterm     — WezTerm Lua color scheme
    terminal    — macOS Terminal.app .terminal (XML plist)
    vscode      — VS Code color theme JSON
    sublime     — Sublime Text .tmTheme (XML)
    xcode       — Xcode .xccolortheme (XML plist)
    all         — generate all targets

Inspired by Selenized's template pipeline and Modus's semantic roles.
"""

import argparse
import os
import sys
import json
from pathlib import Path

try:
    import yaml
except ImportError:
    print("PyYAML required: pip install pyyaml", file=sys.stderr)
    sys.exit(1)


# ═══════════════════════════════════════════════════════════════════════
# Core: Load & Resolve
# ═══════════════════════════════════════════════════════════════════════

def load_theme(path: str) -> dict:
    """Load a YAML theme definition."""
    with open(path) as f:
        return yaml.safe_load(f)


def resolve_role(theme: dict, role_value: str) -> dict:
    """Resolve a role reference to a palette entry (like Modus's recursive resolver)."""
    palette = theme["palette"]
    # role_value is a palette key name
    if role_value in palette:
        return palette[role_value]
    raise KeyError(f"Role '{role_value}' not found in palette")


def hex_to_rgb(hex_str: str) -> tuple:
    """Parse '#RRGGBB' to (R, G, B) integers."""
    h = hex_str.lstrip("#")
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))


def rgb_to_float(r, g, b) -> tuple:
    """Convert 0-255 RGB to 0.0-1.0 floats."""
    return r / 255.0, g / 255.0, b / 255.0


def get_hex(theme: dict, role_path: str) -> str:
    """Get hex color for a role path like 'roles.ansi.red' or 'roles.background'."""
    parts = role_path.split(".")
    roles = theme["roles"]

    # Navigate to the role value
    val = roles
    for part in parts:
        val = val[part]

    # val is now a palette key name — resolve it
    return theme["palette"][val]["hex"]


def get_all_terminal_colors(theme: dict) -> dict:
    """Extract all terminal-relevant colors resolved to hex."""
    roles = theme["roles"]
    palette = theme["palette"]

    def resolve(name):
        return palette[name]["hex"]

    ansi = roles["ansi"]
    return {
        "name":       theme["metadata"]["name"],
        "bg":         resolve(roles["background"]),
        "fg":         resolve(roles["foreground"]),
        "cursor":     resolve(roles["cursor"]),
        "cursor_text":resolve(roles["cursor-text"]),
        "selection":  resolve(roles["selection"]),
        "sel_text":   resolve(roles.get("selection-text", roles["foreground"])),
        "bold":       resolve(roles.get("text-emphasis", roles["foreground"])),
        "link":       resolve(roles["link"]),
        "badge":      resolve(roles.get("badge", roles["foreground"])),

        "ansi0":  resolve(ansi["black"]),
        "ansi1":  resolve(ansi["red"]),
        "ansi2":  resolve(ansi["green"]),
        "ansi3":  resolve(ansi["yellow"]),
        "ansi4":  resolve(ansi["blue"]),
        "ansi5":  resolve(ansi["magenta"]),
        "ansi6":  resolve(ansi["cyan"]),
        "ansi7":  resolve(ansi["white"]),
        "ansi8":  resolve(ansi["bright-black"]),
        "ansi9":  resolve(ansi["bright-red"]),
        "ansi10": resolve(ansi["bright-green"]),
        "ansi11": resolve(ansi["bright-yellow"]),
        "ansi12": resolve(ansi["bright-blue"]),
        "ansi13": resolve(ansi["bright-magenta"]),
        "ansi14": resolve(ansi["bright-cyan"]),
        "ansi15": resolve(ansi["bright-white"]),
    }


def get_all_editor_colors(theme: dict) -> dict:
    """Extract all editor/IDE-relevant colors resolved to hex."""
    roles = theme["roles"]
    palette = theme["palette"]

    def resolve(name):
        return palette[name]["hex"]

    colors = {}
    # Skip nested dicts (like 'ansi')
    for key, val in roles.items():
        if isinstance(val, str):
            colors[key] = resolve(val)
    return colors


# ═══════════════════════════════════════════════════════════════════════
# Generators
# ═══════════════════════════════════════════════════════════════════════

def gen_iterm2(theme: dict) -> str:
    """Generate iTerm2 .itermcolors XML plist."""
    c = get_all_terminal_colors(theme)

    def color_dict(hex_str, alpha=1.0):
        r, g, b = hex_to_rgb(hex_str)
        rf, gf, bf = rgb_to_float(r, g, b)
        return f"""\t<dict>
\t\t<key>Alpha Component</key>
\t\t<real>{alpha}</real>
\t\t<key>Blue Component</key>
\t\t<real>{bf:.17f}</real>
\t\t<key>Color Space</key>
\t\t<string>sRGB</string>
\t\t<key>Green Component</key>
\t\t<real>{gf:.17f}</real>
\t\t<key>Red Component</key>
\t\t<real>{rf:.17f}</real>
\t</dict>"""

    ansi_keys = [
        ("Ansi 0 Color",  "ansi0"),  ("Ansi 1 Color",  "ansi1"),
        ("Ansi 2 Color",  "ansi2"),  ("Ansi 3 Color",  "ansi3"),
        ("Ansi 4 Color",  "ansi4"),  ("Ansi 5 Color",  "ansi5"),
        ("Ansi 6 Color",  "ansi6"),  ("Ansi 7 Color",  "ansi7"),
        ("Ansi 8 Color",  "ansi8"),  ("Ansi 9 Color",  "ansi9"),
        ("Ansi 10 Color", "ansi10"), ("Ansi 11 Color", "ansi11"),
        ("Ansi 12 Color", "ansi12"), ("Ansi 13 Color", "ansi13"),
        ("Ansi 14 Color", "ansi14"), ("Ansi 15 Color", "ansi15"),
    ]

    entries = []
    for plist_key, color_key in ansi_keys:
        entries.append(f"\t<key>{plist_key}</key>\n{color_dict(c[color_key])}")

    ui_keys = [
        ("Background Color",    "bg",         1.0),
        ("Badge Color",         "badge",      0.5),
        ("Bold Color",          "bold",       1.0),
        ("Cursor Color",        "cursor",     1.0),
        ("Cursor Guide Color",  "ansi4",      0.25),
        ("Cursor Text Color",   "cursor_text",1.0),
        ("Foreground Color",    "fg",         1.0),
        ("Link Color",          "link",       1.0),
        ("Selected Text Color", "sel_text",   1.0),
        ("Selection Color",     "selection",  1.0),
    ]

    for plist_key, color_key, alpha in ui_keys:
        entries.append(f"\t<key>{plist_key}</key>\n{color_dict(c[color_key], alpha)}")

    entries.append(f'\t<key>Name</key>\n\t<string>{c["name"]}</string>')
    body = "\n".join(entries)

    return f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
{body}
</dict>
</plist>
"""


def gen_ghostty(theme: dict) -> str:
    """Generate Ghostty config fragment."""
    c = get_all_terminal_colors(theme)
    lines = [f"# {c['name']} — Ghostty color scheme", ""]
    lines.append(f"background = {c['bg']}")
    lines.append(f"foreground = {c['fg']}")
    lines.append(f"cursor-color = {c['cursor']}")
    lines.append(f"cursor-text = {c['cursor_text']}")
    lines.append(f"selection-background = {c['selection']}")
    lines.append(f"selection-foreground = {c['sel_text']}")
    lines.append("")
    for i in range(16):
        lines.append(f"palette = {i}={c[f'ansi{i}']}")
    return "\n".join(lines) + "\n"


def gen_alacritty(theme: dict) -> str:
    """Generate Alacritty TOML color theme."""
    c = get_all_terminal_colors(theme)

    def q(hex_str):
        return f'"{hex_str}"'

    return f"""# {c['name']} — Alacritty color scheme

[colors.primary]
background = {q(c['bg'])}
foreground = {q(c['fg'])}

[colors.cursor]
cursor = {q(c['cursor'])}
text = {q(c['cursor_text'])}

[colors.selection]
background = {q(c['selection'])}
text = {q(c['sel_text'])}

[colors.normal]
black   = {q(c['ansi0'])}
red     = {q(c['ansi1'])}
green   = {q(c['ansi2'])}
yellow  = {q(c['ansi3'])}
blue    = {q(c['ansi4'])}
magenta = {q(c['ansi5'])}
cyan    = {q(c['ansi6'])}
white   = {q(c['ansi7'])}

[colors.bright]
black   = {q(c['ansi8'])}
red     = {q(c['ansi9'])}
green   = {q(c['ansi10'])}
yellow  = {q(c['ansi11'])}
blue    = {q(c['ansi12'])}
magenta = {q(c['ansi13'])}
cyan    = {q(c['ansi14'])}
white   = {q(c['ansi15'])}
"""


def gen_kitty(theme: dict) -> str:
    """Generate Kitty terminal config."""
    c = get_all_terminal_colors(theme)
    lines = [f"# {c['name']} — Kitty color scheme", ""]
    lines.append(f"foreground {c['fg']}")
    lines.append(f"background {c['bg']}")
    lines.append(f"cursor {c['cursor']}")
    lines.append(f"cursor_text_color {c['cursor_text']}")
    lines.append(f"selection_foreground {c['sel_text']}")
    lines.append(f"selection_background {c['selection']}")
    lines.append(f"url_color {c['link']}")
    lines.append("")
    names = ["black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"]
    for i, name in enumerate(names):
        lines.append(f"color{i} {c[f'ansi{i}']}")
    for i, name in enumerate(names):
        lines.append(f"color{i+8} {c[f'ansi{i+8}']}")
    return "\n".join(lines) + "\n"


def gen_wezterm(theme: dict) -> str:
    """Generate WezTerm Lua color scheme."""
    c = get_all_terminal_colors(theme)
    name = c['name']

    ansi = ", ".join(f'"{c[f"ansi{i}"]}"' for i in range(8))
    brights = ", ".join(f'"{c[f"ansi{i+8}"]}"' for i in range(8))

    return f"""-- {name} — WezTerm color scheme

return {{
  ["metadata"] = {{
    name = "{name}",
  }},

  ["colors"] = {{
    foreground = "{c['fg']}",
    background = "{c['bg']}",
    cursor_fg = "{c['cursor_text']}",
    cursor_bg = "{c['cursor']}",
    selection_fg = "{c['sel_text']}",
    selection_bg = "{c['selection']}",

    ansi = {{ {ansi} }},
    brights = {{ {brights} }},
  }},
}}
"""


def gen_terminal_app(theme: dict) -> str:
    """Generate macOS Terminal.app .terminal plist."""
    c = get_all_terminal_colors(theme)

    def ns_color_data(hex_str):
        """Encode as NSArchiver bplist for Terminal.app (simplified RGB)."""
        r, g, b = hex_to_rgb(hex_str)
        rf, gf, bf = rgb_to_float(r, g, b)
        # Terminal.app uses NSKeyedArchiver binary data for colors.
        # For a text-based approach, we output the RGB values as comments
        # and note that Terminal.app requires binary plist conversion.
        return f"<!-- RGB: {rf:.4f} {gf:.4f} {bf:.4f} ({hex_str}) -->"

    lines = [f"<!-- {c['name']} — macOS Terminal.app -->"]
    lines.append("<!-- Note: Terminal.app uses NSKeyedArchiver binary color data. -->")
    lines.append("<!-- Use a tool like terminal-colors or dynamic-colors to convert. -->")
    lines.append(f"<!-- Background: {c['bg']} -->")
    lines.append(f"<!-- Foreground: {c['fg']} -->")
    lines.append(f"<!-- Cursor: {c['cursor']} -->")
    for i in range(16):
        lines.append(f"<!-- ANSI {i}: {c[f'ansi{i}']} -->")
    return "\n".join(lines) + "\n"


def gen_vscode(theme: dict) -> str:
    """Generate VS Code color theme JSON."""
    c = get_all_terminal_colors(theme)
    e = get_all_editor_colors(theme)
    name = theme["metadata"]["name"]
    variant = theme["metadata"]["variant"]

    obj = {
        "name": name,
        "type": variant,
        "colors": {
            # Editor
            "editor.background": e["background"],
            "editor.foreground": e["foreground"],
            "editor.lineHighlightBackground": e.get("line-highlight", e["background"]),
            "editor.selectionBackground": e["selection"],
            "editor.findMatchBackground": e.get("find-match", e["selection"]),
            "editorCursor.foreground": e["cursor"],
            "editorLineNumber.foreground": e["text-muted"],
            "editorLineNumber.activeForeground": e["foreground"],
            "editorLink.activeForeground": e["link"],

            # Sidebar
            "sideBar.background": e.get("line-highlight", e["background"]),
            "sideBar.foreground": e["foreground"],
            "sideBar.border": e["border"],

            # Activity bar
            "activityBar.background": e["background"],
            "activityBar.foreground": e["foreground"],

            # Status bar
            "statusBar.background": e.get("line-highlight", e["background"]),
            "statusBar.foreground": e["foreground"],

            # Tab bar
            "tab.activeBackground": e["background"],
            "tab.activeForeground": e["foreground"],
            "tab.inactiveBackground": e.get("line-highlight", e["background"]),
            "tab.inactiveForeground": e["text-muted"],

            # Terminal
            "terminal.background": e["background"],
            "terminal.foreground": e["foreground"],
            "terminal.ansiBlack":         c["ansi0"],
            "terminal.ansiRed":           c["ansi1"],
            "terminal.ansiGreen":         c["ansi2"],
            "terminal.ansiYellow":        c["ansi3"],
            "terminal.ansiBlue":          c["ansi4"],
            "terminal.ansiMagenta":       c["ansi5"],
            "terminal.ansiCyan":          c["ansi6"],
            "terminal.ansiWhite":         c["ansi7"],
            "terminal.ansiBrightBlack":   c["ansi8"],
            "terminal.ansiBrightRed":     c["ansi9"],
            "terminal.ansiBrightGreen":   c["ansi10"],
            "terminal.ansiBrightYellow":  c["ansi11"],
            "terminal.ansiBrightBlue":    c["ansi12"],
            "terminal.ansiBrightMagenta": c["ansi13"],
            "terminal.ansiBrightCyan":    c["ansi14"],
            "terminal.ansiBrightWhite":   c["ansi15"],

            # Diagnostics
            "editorError.foreground": e["error"],
            "editorWarning.foreground": e["warning"],
            "editorInfo.foreground": e["info"],

            # Diff
            "diffEditor.insertedTextBackground": e["added"] + "22",
            "diffEditor.removedTextBackground": e["deleted"] + "22",
        },
        "tokenColors": [
            {"scope": "comment", "settings": {"foreground": e["comment"]}},
            {"scope": "string", "settings": {"foreground": e["string"]}},
            {"scope": "constant.numeric", "settings": {"foreground": e["number"]}},
            {"scope": "constant.language", "settings": {"foreground": e["constant"]}},
            {"scope": "keyword", "settings": {"foreground": e["keyword"]}},
            {"scope": "storage.type", "settings": {"foreground": e["type"]}},
            {"scope": "entity.name.function", "settings": {"foreground": e["function"]}},
            {"scope": "variable", "settings": {"foreground": e["variable"]}},
            {"scope": "variable.parameter", "settings": {"foreground": e["parameter"]}},
            {"scope": "entity.name.type", "settings": {"foreground": e["type"]}},
            {"scope": "entity.name.tag", "settings": {"foreground": e["tag"]}},
            {"scope": "entity.other.attribute-name", "settings": {"foreground": e["attribute"]}},
            {"scope": "support.function", "settings": {"foreground": e["function"]}},
            {"scope": "meta.decorator", "settings": {"foreground": e["decorator"]}},
            {"scope": "string.regexp", "settings": {"foreground": e["regexp"]}},
            {"scope": "punctuation", "settings": {"foreground": e["punctuation"]}},
            {"scope": "keyword.operator", "settings": {"foreground": e["operator"]}},
            {"scope": "entity.other.inherited-class", "settings": {"foreground": e["type"]}},
            {"scope": "markup.heading", "settings": {"foreground": e["text-emphasis"]}},
            {"scope": "markup.bold", "settings": {"fontStyle": "bold"}},
            {"scope": "markup.italic", "settings": {"fontStyle": "italic"}},
            {"scope": "markup.inserted", "settings": {"foreground": e["added"]}},
            {"scope": "markup.deleted", "settings": {"foreground": e["deleted"]}},
            {"scope": "markup.changed", "settings": {"foreground": e["modified"]}},
        ],
    }

    return json.dumps(obj, indent=2) + "\n"


def gen_sublime(theme: dict) -> str:
    """Generate Sublime Text .tmTheme (TextMate format)."""
    e = get_all_editor_colors(theme)
    c = get_all_terminal_colors(theme)
    name = theme["metadata"]["name"]

    scope_entries = [
        ("Comment",       "comment",    e["comment"]),
        ("String",        "string",     e["string"]),
        ("Number",        "constant.numeric", e["number"]),
        ("Keyword",       "keyword",    e["keyword"]),
        ("Storage",       "storage",    e["keyword"]),
        ("Type",          "entity.name.type, support.type", e["type"]),
        ("Function",      "entity.name.function, support.function", e["function"]),
        ("Variable",      "variable",   e["variable"]),
        ("Parameter",     "variable.parameter", e["parameter"]),
        ("Constant",      "constant.language, constant.other", e["constant"]),
        ("Tag",           "entity.name.tag", e["tag"]),
        ("Attribute",     "entity.other.attribute-name", e["attribute"]),
        ("Decorator",     "meta.annotation, meta.decorator", e["decorator"]),
        ("String Regexp", "string.regexp", e["regexp"]),
        ("Punctuation",   "punctuation", e["punctuation"]),
    ]

    dicts = []
    for label, scope, fg in scope_entries:
        dicts.append(f"""		<dict>
			<key>name</key>
			<string>{label}</string>
			<key>scope</key>
			<string>{scope}</string>
			<key>settings</key>
			<dict>
				<key>foreground</key>
				<string>{fg}</string>
			</dict>
		</dict>""")

    scope_body = "\n".join(dicts)

    return f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>name</key>
	<string>{name}</string>
	<key>settings</key>
	<array>
		<dict>
			<key>settings</key>
			<dict>
				<key>background</key>
				<string>{e['background']}</string>
				<key>foreground</key>
				<string>{e['foreground']}</string>
				<key>caret</key>
				<string>{e['cursor']}</string>
				<key>selection</key>
				<string>{e['selection']}</string>
				<key>lineHighlight</key>
				<string>{e.get('line-highlight', e['background'])}</string>
				<key>findHighlight</key>
				<string>{e.get('find-match', e['selection'])}</string>
			</dict>
		</dict>
{scope_body}
	</array>
</dict>
</plist>
"""


def gen_xcode(theme: dict) -> str:
    """Generate Xcode .xccolortheme (simplified DVTTextSyntaxFont plist)."""
    e = get_all_editor_colors(theme)
    name = theme["metadata"]["name"]

    def xc_color(hex_str):
        r, g, b = hex_to_rgb(hex_str)
        rf, gf, bf = rgb_to_float(r, g, b)
        return f"{rf:.4f} {gf:.4f} {bf:.4f} 1"

    entries = {
        "DVTSourceTextBackground":                xc_color(e["background"]),
        "DVTSourceTextForeground":                xc_color(e["foreground"]),
        "DVTSourceTextInsertionPointColor":        xc_color(e["cursor"]),
        "DVTSourceTextSelectionColor":             xc_color(e["selection"]),
        "DVTSourceTextCurrentLineHighlightColor":  xc_color(e.get("line-highlight", e["background"])),
        "DVTSourceTextSyntaxColorComment":         xc_color(e["comment"]),
        "DVTSourceTextSyntaxColorString":          xc_color(e["string"]),
        "DVTSourceTextSyntaxColorNumber":          xc_color(e["number"]),
        "DVTSourceTextSyntaxColorKeyword":         xc_color(e["keyword"]),
        "DVTSourceTextSyntaxColorType":            xc_color(e["type"]),
        "DVTSourceTextSyntaxColorIdentifier":      xc_color(e["variable"]),
        "DVTSourceTextSyntaxColorAttribute":       xc_color(e["attribute"]),
        "DVTSourceTextSyntaxColorCharacter":       xc_color(e["constant"]),
        "DVTSourceTextSyntaxColorURL":             xc_color(e["link"]),
        "DVTMarkupTextNormalColor":                xc_color(e["foreground"]),
        "DVTConsoleTextBackgroundColor":           xc_color(e["background"]),
    }

    items = []
    for k, v in entries.items():
        items.append(f"\t<key>{k}</key>\n\t<string>{v}</string>")

    body = "\n".join(items)
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<!-- {name} — Xcode color theme -->
<plist version="1.0">
<dict>
{body}
</dict>
</plist>
"""


# ═══════════════════════════════════════════════════════════════════════
# Dispatch
# ═══════════════════════════════════════════════════════════════════════

GENERATORS = {
    "iterm2":    (gen_iterm2,       ".itermcolors"),
    "ghostty":   (gen_ghostty,      ".ghostty"),
    "alacritty": (gen_alacritty,    ".toml"),
    "kitty":     (gen_kitty,        ".conf"),
    "wezterm":   (gen_wezterm,      ".lua"),
    "terminal":  (gen_terminal_app, ".terminal"),
    "vscode":    (gen_vscode,       "-color-theme.json"),
    "sublime":   (gen_sublime,      ".tmTheme"),
    "xcode":     (gen_xcode,        ".xccolortheme"),
}


def main():
    parser = argparse.ArgumentParser(
        description="Generate theme configs from a universal YAML definition"
    )
    parser.add_argument("theme", help="Path to theme YAML file")
    parser.add_argument(
        "--target", "-t",
        required=True,
        choices=list(GENERATORS.keys()) + ["all"],
        help="Output target format"
    )
    parser.add_argument(
        "--outdir", "-o",
        default="./output",
        help="Output directory (default: ./output)"
    )
    args = parser.parse_args()

    theme = load_theme(args.theme)
    slug = theme["metadata"]["slug"]
    name = theme["metadata"]["name"]
    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    targets = list(GENERATORS.keys()) if args.target == "all" else [args.target]

    for target in targets:
        gen_fn, ext = GENERATORS[target]
        output = gen_fn(theme)
        out_path = outdir / f"{slug}{ext}"
        with open(out_path, "w") as f:
            f.write(output)
        print(f"  ✓ {target:10s} → {out_path}")

    print(f"\n  Generated {len(targets)} config(s) for '{name}'")


if __name__ == "__main__":
    main()
