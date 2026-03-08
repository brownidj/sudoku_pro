"""
generate_ocean_images.py

Generate square-framed National Geographic–style marine creature images
for Sudoku tiles using the OpenAI image generation API.

Output:
assets/images/marine/
    1_butterflyfish.png
    2_octopus.png
    3_crab.png
    4_seahorse.png
    5_starfish.png
    6_walrus.png
    7_shark.png
    8_jellyfish.png
    9_turtle.png
"""

from pathlib import Path
import base64
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

client = OpenAI()

OUTPUT_DIR = Path("/Users/david/PycharmProjects/Sudoku_02/flutter_app/assets/images/marine")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

ANIMALS = [
    ("butterflyfish", "side view, tall body"),
    ("octopus", "top view with tentacles spread"),
    ("crab", "top view"),
    ("seahorse", "upright side view"),
    ("starfish", "top view"),
    ("walrus", "front-facing head and upper body with tusks visible"),
    ("shark", "head-on with mouth slightly open"),
    ("jellyfish", "centered dome with tentacles hanging"),
    ("turtle", "top view shell"),
]


def build_prompt(animal: str, pose: str) -> str:
    return (
        f"Create a high-resolution wildlife photograph of a {animal}, isolated on a transparent background, "
        f"styled like a National Geographic field guide photograph. "
        f"The animal should be centered and framed for a square composition, filling roughly 70–80% of the frame. "
        f"The pose should be {pose}. "
        f"Use even studio lighting with natural colour and clear anatomical detail. "
        f"The subject must be fully visible with no cropping. "
        f"No environment, scenery, water, text, watermark, background fill, gradient background, or additional objects. "
        f"Only the animal with transparent empty space around it."
    )


def generate_image(prompt: str, filename: Path):
    result = client.images.generate(
        model="gpt-image-1",
        prompt=prompt,
        size="1024x1024",
        background="transparent",
    )

    image_base64 = result.data[0].b64_json
    image_bytes = base64.b64decode(image_base64)

    with open(filename, "wb") as f:
        f.write(image_bytes)


def main():
    for i, (animal, pose) in enumerate(ANIMALS, start=1):
        filename = OUTPUT_DIR / f"{i}_{animal}.png"
        prompt = build_prompt(animal, pose)

        print("Generating:", filename.name)
        generate_image(prompt, filename)

    print("Done.")


if __name__ == "__main__":
    main()
