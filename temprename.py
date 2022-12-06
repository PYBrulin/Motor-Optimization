import glob
import os
import sys

from PIL import Image

path = sys.argv[1]
if not os.path.exists(path):
    sys.exit(1)

motor_name = os.path.basename(path)

fp_in = "*.bmp"

imgs_list = sorted(glob.glob(os.path.join(path, fp_in)))

# print(imgs_list)
for i in imgs_list:
    # print(
    #     os.path.dirname(i),
    #     os.path.splitext(os.path.basename(i))[0],
    #     os.path.splitext(os.path.basename(i))[1],
    # )

    # print("%08.3f" % float(os.path.splitext(os.path.basename(i))[0].split("_")[0]))

    print(
        os.path.join(
            os.path.dirname(i),
            "%08.3f" % float(os.path.splitext(os.path.basename(i))[0].split("_")[0])
            + "_"
            + os.path.splitext(os.path.basename(i))[0].split("_")[1]
            + os.path.splitext(os.path.basename(i))[1],
        )
    )
    os.rename(
        i,
        os.path.join(
            os.path.dirname(i),
            "%08.3f" % float(os.path.splitext(os.path.basename(i))[0].split("_")[0])
            + "_"
            + os.path.splitext(os.path.basename(i))[0].split("_")[1]
            + os.path.splitext(os.path.basename(i))[1],
        ),
    )
