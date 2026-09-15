"""Generate Offline SQL Fixer logo (no internet needed, Pillow only).
Concept: deep-navy rounded app tile + white database cylinder + amber fix-bolt.
Output: assets/logo/app_icon.png (1024) used by flutter_launcher_icons + in-app header.
"""
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "logo"
OUT.mkdir(parents=True, exist_ok=True)

S = 1024
NAVY_TOP = (30, 27, 75)      # #1E1B4B
NAVY_BOT = (14, 27, 51)      # #0E1B33
WHITE = (255, 255, 255)
STEEL = (199, 210, 254)
AMBER = (245, 158, 11)
AMBER_D = (217, 119, 6)

img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
d = ImageDraw.Draw(img)

# rounded tile with full-bleed vertical gradient (mask for clean corners)
r = 230
tile = Image.new("RGBA", (S, S), (0, 0, 0, 0))
td = ImageDraw.Draw(tile)
for y in range(S):
    t = y / S
    c = tuple(int(NAVY_TOP[i] + (NAVY_BOT[i] - NAVY_TOP[i]) * t) for i in range(3))
    td.line([(0, y), (S, y)], fill=c)
mask = Image.new("L", (S, S), 0)
ImageDraw.Draw(mask).rounded_rectangle([0, 0, S, S], radius=r, fill=255)
img.paste(tile, (0, 0), mask)
d = ImageDraw.Draw(img)

cx = S // 2
# database cylinder (body)
db_w, db_top, db_bot = 470, 300, 660
d.ellipse([cx - db_w // 2, db_top - 70, cx + db_w // 2, db_top + 70], fill=STEEL)
d.rectangle([cx - db_w // 2, db_top, cx + db_w // 2, db_bot], fill=WHITE)
d.ellipse([cx - db_w // 2, db_bot - 70, cx + db_w // 2, db_bot + 70], fill=WHITE)
d.ellipse([cx - db_w // 2, db_top - 70, cx + db_w // 2, db_top + 70], outline=NAVY_BOT, width=10)
d.arc([cx - db_w // 2, db_top + 30, cx + db_w // 2, db_top + 170], start=0, end=180, fill=STEEL, width=10)
d.arc([cx - db_w // 2, db_top + 130, cx + db_w // 2, db_top + 270], start=0, end=180, fill=STEEL, width=10)

# amber lightning bolt (the "fix") over the cylinder
bolt = [(560, 380), (440, 600), (510, 600), (470, 730), (610, 540), (535, 540)]
d.polygon(bolt, fill=AMBER, outline=AMBER_D)

# small wifi-off badge: green dot with white ring, bottom-right
bx, by, br = 800, 800, 90
d.ellipse([bx - br, by - br, bx + br, by + br], fill=(16, 185, 129))
d.ellipse([bx - br, by - br, bx + br, by + br], outline=WHITE, width=14)
d.line([(bx - 45, by + 10), (bx + 45, by + 10)], fill=WHITE, width=22)  # minus = offline
# wifi arcs crossed subtly
d.arc([bx - 60, by - 70, bx + 60, by + 50], start=200, end=340, fill=WHITE, width=12)

out = OUT / "app_icon.png"
img.save(out)
print(f"saved {out} ({S}x{S})")
