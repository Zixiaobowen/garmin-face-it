#!/usr/bin/env python3
"""Resize the original ZSvirt logos to the Enduro 3 four-level gray palette."""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]


def render(source, destination, width, height=None):
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
    palette = Image.new("P", (1, 1))
    palette.putpalette([channel for level in (0, 85, 170, 255) for channel in (level, level, level)] + [0] * 756)
    result = canvas.convert("RGB").quantize(palette=palette, dither=Image.Dither.NONE)
    output = ROOT / "resources/drawables" / destination
    output.parent.mkdir(parents=True, exist_ok=True)
    result.save(output, optimize=True, bits=2)
    print(f"{output.relative_to(ROOT)}: {width}x{height}")


if __name__ == "__main__":
    render("zsvirt-horizontal-white.png", "zsvirt-logo.png", 160)
    render("zsvirt-symbol-white.png", "launcher-icon.png", 40, 40)
