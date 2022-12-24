from typing import List, Tuple
from PIL import Image
import struct
import argparse
import os

# Speccy palette
speccy_palette = [
    (0, 0, 0), # Black
    (0, 0, 255), # Blue
    (255, 0, 0), # Red
    (255, 0, 255), # Magenta
    (0, 255, 0), # Green
    (0, 255, 255), # Cyan
    (255, 255, 0), # Yellow
    (255, 255, 255) # White
]


def convert_to_speccy_format(type: str) -> List[Tuple[int, int]]:

    # Calculate number of frames
    if(type == "ss" or type == "ls"):
        return outputsprites(type)

    return outputtiles()


def outputtiles():


    #copy input to new
    tile_num = 0

    #create tmp bitmap with clean left 4 pixels
    bitmap = Image.new("RGB", (12, 8))
    color_black = (0, 0, 0)
    for x in range(12):
        for y in range(8):
            bitmap.putpixel((x, y), color_black)

    #get every tile from tileset

    tiles_x = input_image.width // 8
    tiles_y = input_image.height // 8

    tiledata = []
    for ty in range(tiles_y):
        for tx in range(tiles_x):

            # generate one tile

            # copy pixels from input to new
            for x in range(8):
                for y in range(8):
                    bitmap.putpixel((x + 4, y), input_image.getpixel((x + 8 * tx, y + 8 * ty)))

            # Empty bytes array
            bytes = []

            for y in range(bitmap.height):
                # 6 bytes per tile line
                for x in range(6):
                    byte = 0
                    color = bitmap.getpixel((x * 2, y))
                    try:
                        index = speccy_palette.index(color)
                    except ValueError:
                        index = 0

                    byte = (index + 64)

                    color = bitmap.getpixel((x * 2 + 1, y))
                    try:
                        index = speccy_palette.index(color)
                    except ValueError:
                        index = 0
                    byte += (index * 8)
                    bytes.append(byte)

            tiledata.append(bytes)
            tile_num += 1

    return tiledata


def outputsprites(type):

    if(type == "ss"):
        frame_width = 5
    if(type == "ls"):
        frame_width = 11
    
    total_frames = input_image.width // frame_width
    print("Number of frames: {}".format(total_frames))
    print("Frame width: {}".format(input_image.width))


    result = []
    for frame in range(total_frames):
        # Create temporary image with clean right column from source
        tmp_image = Image.new("RGB", (frame_width + 1, input_image.height))
        # Copy pixels from input to temporary image
        for x in range(frame_width):
            for y in range(input_image.height):
                tmp_image.putpixel((x, y), input_image.getpixel((x + frame_width * frame, y)))
                # Fill right column with transparent color
                tmp_image.putpixel((frame_width, y), (10, 10, 10))

        # One frame then simple
        # pop bc       ; grab mask in c and packed byte in b
        # ld a, (hl)   ; grab byte from screen
        # and c        ; apply mask
        # or b         ; or
        # ld(hl), a    ; put in screen
        #
        # Sprite format: byte mask, byte packed data
        result_frame = []

        for y in range(tmp_image.height):
            for x in range(tmp_image.width // 2):
                # All values are default
                mask = 0b11111111
                color = 0b00000000

                # Grab 2 pixels
                color_left = tmp_image.getpixel((x * 2, y))
                color_right = tmp_image.getpixel((x * 2 + 1, y))

                # Grab 2 color indices
                try:
                    color_index_left = speccy_palette.index(color_left)
                except ValueError:
                    color_index_left = -1

                try:
                    color_index_right = speccy_palette.index(color_right)
                except ValueError:
                    color_index_right = -1

                # Enable mask for paper
                if color_index_right >= 0:
                    mask = mask & 0b00000111
                    color = color + (color_index_right << 3)

                # Enable mask for ink
                if color_index_left >= 0:
                    mask = mask & 0b00111000
                    color = color + color_index_left

                result_frame.append(mask)
                result_frame.append(color + 64)

        for y in range(tmp_image.height):
            for x in range(tmp_image.width // 2):
                # Initialize mask and color
                mask = 0b11111111
                color = 0b00000000

                color_index_left = -1
                color_index_right = -1

                if x > 0:
                    color_left = tmp_image.getpixel((x * 2 - 1, y))
                    try:
                        color_index_left = speccy_palette.index(color_left)
                    except ValueError:
                        color_index_left = -1

                color_right = tmp_image.getpixel((x * 2, y))
                try:
                    color_index_right = speccy_palette.index(color_right)
                except ValueError:
                    color_index_right = -1
                    # print('Failed to find color', color_right)
                # Enable mask for paper
                if color_index_right >= 0:
                    mask = mask & 0b00000111
                    color = color + (color_index_right << 3)
                # Enable mask for ink
                if color_index_left >= 0:
                    mask = mask & 0b00111000
                    color = color + color_index_left

                result_frame.append(mask)
                result_frame.append(color + 64)
        result.append(result_frame)
    return result
    
def write_binary(filename, bindata):
    # Open the binary file for writing
    with open(filename, "wb") as f:
    # Iterate over the rows of the 2D array
        for row in bindata:
            # Pack the row into a binary string using the 'H' format
            data = struct.pack("B" * len(row), *row)
            # Write the binary string to the file
            f.write(data)

# Create an ArgumentParser object
parser = argparse.ArgumentParser(description="Convert PNG to Ringo 8 binary format")

# Add an optional argument for the filename
parser.add_argument("filename", nargs="?", help="the file to process")
parser.add_argument("type", nargs="?", help="type of image to process")

# Parse the command line arguments
args = parser.parse_args()

# If the filename argument is not provided, show usage and exit
if args.filename is None:
    parser.print_usage()
    exit()

# Check if the filename argument is a valid file
if not os.path.isfile(args.filename):
    print("File '%s' does not exist or  is not a valid file." % args.filename)
    exit()


# Open the file and check if it is a valid PNG image
input_image = False
try:
    # Import texture to array
    input_image = Image.open(args.filename)

    if input_image.mode!= "RGB" and input_image.mode!="RGBA":
        print("File '%s' is not a valid image." % args.filename)
        exit()

except IOError:
    print("Failed to load image")
    exit()

# Check the image height and width. This is a good indicator of
# the type of image we are dealing with

height = input_image.height
width = input_image.width
tilewidth = 11

print(height, width)

type = args.type

if type is not None:
    height = 0

if(height == 64) or (args.type == "tile") or (args.type == "tiles"):
    type = "tile"
if(height == 12) or (args.type == "ls") or (args.type == "largesprite"):
    type = "ls"
if(height == 5) or (args.type == "ss") or (args.type == "smallsprite"):
    type = "ss"

result = convert_to_speccy_format(type)
write_binary(args.filename + ".bin", result)
