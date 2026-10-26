#!/usr/bin/env python3
"""Reproduce device-sized resources from the official ZSvirt white PNG assets."""
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]


def render(source, destination, width, height=None, monochrome=False):
    image = Image.open(ROOT / "assets" / source).convert("RGBA")
    bounds = image.getchannel("A").getbbox()
    if bounds is None:
        raise ValueError(f"Empty logo: {source}")
    image = image.crop(bounds)
    if height is None:
        height = round(width * image.height / image.width)
        image = image.resize((width, height), Image.Resampling.LANCZOS)
    else:
        image.thumbnail((width, height), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (width, height), (0, 0, 0, 255))
    canvas.alpha_composite(image, ((width - image.width) // 2, (height - image.height) // 2))
    levels = (0, 255) if monochrome else (0, 85, 170, 255)
    palette = Image.new("P", (1, 1))
    colors = [channel for level in levels for channel in (level, level, level)]
    palette.putpalette(colors + [0] * (768 - len(colors)))
    result = canvas.convert("RGB").quantize(palette=palette, dither=Image.Dither.NONE)
    output = ROOT / destination
    output.parent.mkdir(parents=True, exist_ok=True)
    result.save(output, optimize=True, bits=1 if monochrome else 2)
    print(f"{output.relative_to(ROOT)}: {width}x{height}")


def main():
    targets = json.loads((ROOT / "docs/compatibility.json").read_text())["targets"]
    logos = {}
    launchers = {}
    for target in targets:
        width = target["resolution"]["width"]
        logo_width = target["logo_width"]
        if width in logos and logos[width][0] != logo_width:
            raise ValueError(f"Conflicting logo width for screen width {width}")
        palette = target["resource_palette_colors"]
        monochrome = palette is not None and not {"555555", "AAAAAA"}.issubset(palette)
        logos[width] = (logo_width, monochrome or logos.get(width, (0, False))[1])
        icon = target["launcher_icon"]
        size = (icon["width"], icon["height"])
        launchers[size] = monochrome or launchers.get(size, False)
    for width, (logo_width, monochrome) in sorted(logos.items()):
        directory = ROOT / f"resources-logos/{width}"
        render("zsvirt-horizontal-white.png", directory / "zsvirt-logo.png", logo_width,
               monochrome=monochrome)
        (directory / "drawables.xml").write_text(
            '<drawables>\n    <bitmap id="ZsvirtLogo" filename="zsvirt-logo.png" dithering="none"/>\n</drawables>\n')
    for (width, height), monochrome in sorted(launchers.items()):
        directory = ROOT / f"resources-launchers/{width}x{height}"
        render("zsvirt-symbol-white.png", directory / "launcher-icon.png", width, height,
               monochrome=monochrome)
        (directory / "drawables.xml").write_text(
            '<drawables>\n    <bitmap id="LauncherIcon" filename="launcher-icon.png" dithering="none"/>\n</drawables>\n')


if __name__ == "__main__":
    main()
