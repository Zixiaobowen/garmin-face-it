#!/usr/bin/env python3
"""Generate the project's OFL watch-face typography and launcher icon."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import xml.etree.ElementTree as ET
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
LABELS = ("最大摄氧量日出温度体感降雨概率恢复时间周跑量本地七日身体电量未设目标农历星期一二三四五六七八九十初廿卅正冬腊月闰优秀卓越良好一般较低过期无数据心率区天气" +
          "最近分钟前样本小时步数不支持今天未设区间关闭日常训练极简自动主题颜色红蓝绿橙白信息位" +
          "0123456789:/.-%°+ ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
VALUES = "0123456789:/.-%°+ ChkmNA"
FACE_LABELS = "心率身体电量温度恢复周跑量摄氧量日出降雨步数不支持 " + VALUES
DETAILS = "未设目标农历周日一二三四五六七八九十初廿卅正冬腊月闰优秀卓越良好一般较低过期无数据心率区天气最近体感本地今天间不支持" + VALUES + " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
# Group, label, detail, value, time, dense time, ambient time (pixels).
SIZES = [("compact", 10, 9, 16, 47, 32, 28),
         ("small", 12, 11, 18, 65, 48, 31),
         ("240", 13, 12, 21, 72, 53, 36),
         ("260", 14, 12, 23, 78, 57, 39),
         ("280", 15, 13, 24, 84, 62, 42),
         ("360", 19, 17, 31, 108, 80, 54),
         ("390", 21, 18, 34, 117, 86, 59),
         ("416", 22, 19, 36, 125, 92, 62),
         ("454", 24, 21, 39, 136, 101, 68)]


def bitmap_font(font_path, size, alphabet, folder, name, weight):
    font = ImageFont.truetype(str(font_path), size)
    font.set_variation_by_axes([weight])
    chars = sorted(set(alphabet))
    boxes = {ch: font.getbbox(ch) for ch in chars}
    top = min(b[1] for b in boxes.values())
    bottom = max(b[3] for b in boxes.values())
    line_height = bottom - top + 1
    cell_width = max(b[2] - min(0, b[0]) for b in boxes.values()) + 2
    cell_height = line_height + 2
    columns = max(1, 256 // cell_width)
    rows = math.ceil(len(chars) / columns)
    atlas = Image.new("L", (columns * cell_width, rows * cell_height), 0)
    draw = ImageDraw.Draw(atlas)
    records = []
    for idx, ch in enumerate(chars):
        x, y = (idx % columns) * cell_width, (idx // columns) * cell_height
        left, upper, right, lower = boxes[ch]
        width, height = right - left, lower - upper
        draw.text((x - left, y - upper), ch, font=font, fill=255)
        advance = round(font.getlength(ch)) + (1 if ord(ch) < 128 else 0)
        records.append(f"char id={ord(ch)} x={x} y={y} width={width} height={height} xoffset={left} yoffset={upper-top} xadvance={advance} page=0 chnl=15")
    # Monochrome alpha keeps old MIP font memory bounded and eliminates dark fringes.
    mask = atlas.point(lambda p: 255 if p >= 112 else 0)
    image = Image.new("RGBA", atlas.size, (255, 255, 255, 0))
    image.putalpha(mask)
    image.save(folder / f"{name}.png", optimize=True)
    header = [f'info face="ReferenceFace Noto subset" size={size} bold={int(weight >= 600)} italic=0 charset="" unicode=1 stretchH=100 smooth=0 aa=1 padding=0,0,0,0 spacing=1,1',
              f"common lineHeight={line_height} base={bottom-top} scaleW={atlas.width} scaleH={atlas.height} pages=1 packed=0",
              f'page id=0 file="{name}.png"', f"chars count={len(chars)}"]
    (folder / f"{name}.fnt").write_text("\n".join(header + records) + "\n")
    return {"size": size, "weight": weight, "glyphs": len(chars), "width": atlas.width, "height": atlas.height, "lineHeight": line_height}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--font", type=Path, required=True, help="NotoSansSC[wght].ttf from Google Fonts (OFL)")
    args = parser.parse_args()
    if not args.font.is_file():
        parser.error("The source font file is missing")
    labels = LABELS + "".join(element.text for element in
        ET.parse(ROOT / "resources/strings/strings.xml").getroot().findall("string"))
    output = []
    for group, label, detail, value, time, dense, ambient in SIZES:
        folder = ROOT / "resources-fonts" / group
        folder.mkdir(parents=True, exist_ok=True)
        specs = [("Label", label, FACE_LABELS, 550), ("Menu", label, labels, 550),
                 ("Detail", detail, DETAILS, 550),
                 ("Value", value, VALUES, 600), ("Fit", max(7, label * 2 // 3), VALUES, 600),
                 ("Time", time, "0123456789:", 650),
                 ("TimeDense", dense, "0123456789:", 650),
                 ("TimeAmbient", ambient, "0123456789:", 550)]
        record = {"group": group}
        declarations = []
        for identifier, size, alphabet, weight in specs:
            name = identifier.lower()
            record[name] = bitmap_font(args.font, size, alphabet, folder, name, weight)
            declarations.append(f'  <font id="{identifier}" filename="{name}.fnt" />')
        output.append(record)
        (folder / "fonts.xml").write_text("<fonts>\n" + "\n".join(declarations) + "\n</fonts>\n")
    icon_dir = ROOT / "resources" / "drawables"
    icon_dir.mkdir(parents=True, exist_ok=True)
    icon = Image.new("RGBA", (40, 40), (0, 0, 0, 0))
    draw = ImageDraw.Draw(icon)
    draw.ellipse((1, 1, 38, 38), fill="black", outline="red", width=3)
    draw.line((13, 12, 13, 27, 26, 27), fill="white", width=4)
    draw.rectangle((23, 10, 27, 20), fill="red")
    icon.save(icon_dir / "launcher.png")
    (ROOT / "docs" / "font-assets.json").write_text(json.dumps({
        "source": "https://github.com/google/fonts/tree/main/ofl/notosanssc", "license": "SIL OFL 1.1",
        "source_sha256": hashlib.sha256(args.font.read_bytes()).hexdigest(), "fonts": output}, indent=2) + "\n")
    print(f"Generated {len(output)} font groups, {len(set(FACE_LABELS))} face and {len(set(labels))} menu glyphs; icon 40x40")


if __name__ == "__main__":
    main()
