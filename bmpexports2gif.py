import glob
import os
import sys

from PIL import Image

path = sys.argv[1]
if not os.path.exists(path):
    sys.exit(1)

motor_name = os.path.basename(path)

fp_in = "*.bmp"
fp_out = "{}_animation.gif".format(motor_name)

imgs_list  = sorted(glob.glob(os.path.join(path, fp_in)))
print("Combining {} images into: {}".format(len(imgs_list), fp_out))
# https://pillow.readthedocs.io/en/stable/handbook/image-file-formats.html#gif
img, *imgs = [Image.open(f) for f in imgs_list]
img.save(
    fp=fp_out, format="GIF", append_images=imgs, save_all=True, duration=100, loop=0
)
