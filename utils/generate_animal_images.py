from pathlib import Path
import base64
import argparse
from typing import Literal
import sys

try:
    from openai import OpenAI
except ModuleNotFoundError:
    print(
        "Missing dependency: openai\n"
        "Install project dependencies with:\n"
        "  /Users/david/PycharmProjects/Sudoku_02/.venv/bin/python -m pip install -r "
        "/Users/david/PycharmProjects/Sudoku_02/requirements.txt",
        file=sys.stderr,
    )
    raise SystemExit(1)

# ---------------- Configuration ----------------

OUTPUT_DIR = Path("../assets/images/animals_chatGPT")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

MODEL = "gpt-image-1"  # DALL·E image model
IMAGE_SIZE: Literal[
    "auto",
    "1024x1024",
    "1536x1024",
    "1024x1536",
    "256x256",
    "512x512",
    "1792x1024",
    "1024x1792",
] = "1024x1024"

ORDERED_ANIMALS = [
    "ape",
    "buffalo",
    "camel",
    "dolphin",
    "elephant",
    "frog",
    "giraffe",
    "hippo",
    "iguana",
]

ANIMAL_PROMPTS = {
    "ape": """
Create a single cute cartoon ape head in a polished, kid-friendly mobile game icon style. The ape should have a rounded face, big expressive glossy eyes, and a friendly smile. Include small rounded ears, a slightly lighter tan face/muzzle area, and a simple hair cap/tuft on top. Use thick clean dark outlines, smooth gradient shading, and a subtle 3D “sticker” look with gentle inner highlights. Keep details minimal and clean, with warm browns and tans.
Output: ape head only, centered, no text, no grid, no frame, no numbers, no other animals, transparent background (PNG), high resolution, crisp edges.
""".strip(),

    "buffalo": """
Create a single cute cartoon buffalo head in a glossy, kid-friendly mobile game icon style. The buffalo should have a rounded face, big expressive shiny eyes, a gentle smile, and two curved light-grey horns with a soft highlight. Use thick clean dark outlines, smooth gradient shading, and a slight 3D “sticker” look with subtle inner highlights and soft ambient shadowing (but no background shadow cast onto a scene). Keep the color palette warm and simple: dark brown/black body, cream muzzle, light grey horns, minimal detail, very clean edges.
Output: buffalo head only, centered, no text, no grid, no frame, no numbers, no other animals, transparent background (PNG), high resolution, crisp lines suitable for an app tile.
""".strip(),

    "camel": """
Create a single cute cartoon camel head in a polished, kid-friendly mobile game icon style. The camel should have a rounded head, big glossy friendly eyes, and a soft smiling mouth. Include a small rounded snout, simple nostrils, and a hint of fluffy forelock. Add small ears and a warm sandy/tan palette with slightly darker shading around the cheeks and jaw. Use thick clean dark outlines, smooth gradients, and a gentle 3D sticker-like finish with subtle highlights.
Output: camel head only, centered, no extra objects, transparent background (PNG), high resolution, crisp lines.
""".strip(),

    "dolphin": """
Create a single cute cartoon dolphin (head-and-upper-body or full simplified dolphin) in a polished, kid-friendly mobile game icon style. The dolphin should have a smooth rounded silhouette, big glossy eye, and a friendly open smile with a tiny hint of tongue (optional). Use a bright ocean-blue palette with soft gradient shading and clean highlight bands to give a smooth 3D sticker look. Keep fins simple and rounded, with thick clean dark outlines and very clean edges.
Output: dolphin only, centered, no water splashes, no background scene, no text, transparent background (PNG), high resolution.
""".strip(),

    "elephant": """
Create a single cute cartoon elephant head in a polished, kid-friendly mobile game icon style. The elephant should have a rounded head, big glossy eyes, and a friendly smile. Include large rounded ears, a curved trunk (slightly curled at the end), and small simple tusks (optional, tiny). Use a soft grey palette with gentle warm highlights inside the ears (subtle pink/peach). Apply thick clean dark outlines, smooth gradient shading, and a subtle 3D sticker finish with inner highlights.
Output: elephant head only, centered, no extra objects, transparent background (PNG), high resolution, crisp edges.
""".strip(),

    "frog": """
Create a single cute cartoon frog (head or head-and-upper-body) in a polished, kid-friendly mobile game icon style. The frog should have a round, simple shape, big glossy eyes (slightly raised), and a wide friendly smile. Use a bright leaf-green palette with smooth gradients and soft highlights for a slightly 3D sticker look. Keep limbs minimal and rounded if included; avoid complex textures. Use thick clean dark outlines and crisp edges.
Output: frog only, centered, no lily pads, no pond, no text, transparent background (PNG), high resolution.
""".strip(),

    "giraffe": """
Create a single cute cartoon giraffe head in a polished, kid-friendly mobile game icon style. The giraffe should have a rounded face, big glossy eyes, and a gentle smile. Include two small ossicones, short mane ridge, and simple orange/tan spots on a pale cream base. Add small ears and a soft rounded snout. Use thick clean dark outlines, smooth gradient shading, and a subtle 3D sticker finish with gentle highlights and minimal texture.
Output: giraffe head only, centered, no extra items, transparent background (PNG), high resolution.
""".strip(),

    "hippo": """
Create a single cute cartoon hippo head in a polished, kid-friendly mobile game icon style. The hippo should have a rounded, chunky face, big expressive glossy eyes, and a gentle friendly smile. Emphasize a wide rounded snout with two small nostrils, tiny ears on top, and simple cheek contours. Use a soft grey / lavender-grey palette with subtle warm pink inside the ears (very light), smooth gradient shading, and a slight 3D “sticker” look with clean inner highlights. Keep details minimal, clean, and cute. Use thick clean dark outlines, crisp edges, and a soft polished finish.
Output: hippo head only, centered, no text, no grid, no frame, no numbers, no other animals, transparent background (PNG), high resolution, crisp lines suitable for an app tile.
""".strip(),

    "iguana": """
Create a single cute cartoon iguana in a polished, kid-friendly mobile game icon style. The iguana should have a smooth, rounded head with a friendly expression, big glossy expressive eye, and a gentle smile. Include the iconic iguana features in a simplified way: a row of small rounded dorsal spines along the top of the head/neck, a subtle dewlap (throat flap) shape, and a slightly textured cheek/jaw line suggested with clean shapes (not detailed scales). Use a bright leafy-green palette with smooth gradient shading and soft highlights for a slight 3D “sticker” look, plus thick clean dark outlines and crisp edges. Keep the silhouette bold and readable at small sizes.
Output: iguana only (head-only or head-and-upper-neck), centered, no text, no grid, no frame, no numbers, no other animals, transparent background (PNG), high resolution, clean edges suitable for an app tile.
""".strip(),
}

BASE_PROMPT = """
Using DALL-E, create a simple, clean line-drawing illustration of a {animal}'s face,
three-quarter-facing to the right and centered.

Use smooth, confident black outlines with minimal detail.
Apply a small amount of flat, muted colour only where appropriate
(e.g. ears, nose, markings), avoiding gradients or shading.

The style should be modern, neutral expression, and icon-like —
suitable for educational materials or UI icons.
Transparent background.

Emphasise clear shapes, symmetry, recognisable features,
anatomically recognisable features, restrained colour palette.

No photorealism.
No shading or gradients.
No complex textures.
No background scenes.
No text or watermark.
No sketchy lines or cross-hatching.
No realism or heavy textures.
""".strip()


# ---------------- Client ----------------

client = OpenAI()

# ---------------- Helpers ----------------

def generate_image(prompt: str, out_path: Path) -> None:
    """Generate one image and save it to disk."""
    result = client.images.generate(
        model=MODEL,
        prompt=prompt,
        size=IMAGE_SIZE,
        background="transparent",
    )

    image_base64 = result.data[0].b64_json
    image_bytes = base64.b64decode(image_base64)

    out_path.write_bytes(image_bytes)
    print(f"Saved: {out_path.name}")

# ---------------- Main ----------------

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate cartoon animal icons with DALL·E")
    parser.add_argument(
        "--test",
        action="store_true",
        help="Test run: generate only the first two animals",
    )
    parser.add_argument(
        "--base",
        action="store_true",
        help="Use BASE_PROMPT line-drawing style and legacy naming (<n>_<animal>.png)",
    )
    return parser.parse_args()

def main(test_run: bool = False, use_base: bool = False) -> None:
    animals = ORDERED_ANIMALS[:2] if test_run else ORDERED_ANIMALS
    for animal in animals:
        idx = ORDERED_ANIMALS.index(animal) + 1

        if use_base:
            prompt = BASE_PROMPT.format(animal=animal)
            out_file = OUTPUT_DIR / f"{idx}_{animal}.png"
        else:
            prompt = ANIMAL_PROMPTS[animal]
            out_file = OUTPUT_DIR / f"{idx}_cartoon_{animal}.png"

        if out_file.exists():
            print(f"Skipping (already exists): {out_file.name}")
            continue

        generate_image(prompt, out_file)


if __name__ == "__main__":
    args = parse_args()
    main(test_run=args.test, use_base=args.base)
