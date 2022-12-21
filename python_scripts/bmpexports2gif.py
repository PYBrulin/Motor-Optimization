import glob
import os
import sys

from PIL import Image

path: str = sys.argv[1]
if not os.path.exists(path):
    sys.exit(1)

# Get the last not empty folder basename
motor_name: str = os.path.basename(path)
while not motor_name:
    path = os.path.dirname(path)
    motor_name = os.path.basename(path)


# list bmp files in path and find the groups of images defined by the first number in the filename
# e.g. 1_1.bmp, 1_2.bmp, 1_3.bmp, 2_1.bmp, 2_2.bmp, 2_3.bmp, 3_1.bmp, 3_2.bmp, 3_3.bmp
# will be grouped into 3 groups: 1_1.bmp, 1_2.bmp, 1_3.bmp; 2_1.bmp, 2_2.bmp, 2_3.bmp; 3_1.bmp, 3_2.bmp, 3_3.bmp
# and each group will be exported as a gif animation

list_of_files = glob.glob(os.path.join(path, "*.bmp"))
list_of_files.sort()

# Get the first number in the filename
list_of_currents = sorted(
    set([os.path.basename(x).split("_")[0] for x in list_of_files])
)
print(list_of_currents)

# Ask the user to select the current to export
print("Select the current to export:")

print("-1: All currents")
for i, current in enumerate(list_of_currents):
    print("{}: {}".format(i, current))

current_index = int(input("Enter the number: "))
if current_index == -1:
    print("Exporting all currents")
else:
    current = list_of_currents[current_index]
    print("Selected current: {}".format(current))

    # Get the list of files for the selected current
    list_of_files = sorted(
        [x for x in list_of_files if os.path.basename(x).startswith(current)]
    )

# Output file
fp_out: str = "figures/{}_animation.gif".format(motor_name)
print("Output: {}".format(fp_out))

q: int = 10  # Quality
ratio: float = 1  # Resize ratio

# Open the first image to get the size
img_0 = Image.open(sorted(list_of_files)[0])
x: int = int(img_0.size[0] * ratio)
y: int = int(img_0.size[1] * ratio)

print("Combining {} images into: {}".format(len(list_of_files), fp_out))
# https://pillow.readthedocs.io/en/stable/handbook/image-file-formats.html#gif
img, *imgs = [
    Image.open(f).resize((x, y), Image.Resampling.LANCZOS) for f in list_of_files
]

img.save(
    fp=fp_out,
    format="GIF",
    append_images=imgs,
    quality=q,
    save_all=True,
    optimize=True,
    duration=100,
    loop=0,
)
