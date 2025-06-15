# SIMULATING THE SHAPE GEN TO WORK OUT A BETTER WAY TO BUILD IT

import numpy as np
from PIL import Image

# Grid size
width, height = 800, 600

# Circle center and radius
cx, cy = 400, 300
radius = 200

# Create grid of coordinates
y_coords, x_coords = np.ogrid[:height, :width]

# === 1. Distance Map ===
dist = np.sqrt((x_coords - cx)**2 + (y_coords - cy)**2)
dist_normalized = (dist / dist.max()) * 255
dist_image = dist_normalized.astype(np.uint8)
Image.fromarray(dist_image).save("distance_map.png")

# ===  Circle ===
stripe_mod_threshold = 2
x_mod = x_coords % 4
inside_circle = dist <= radius
# stripe_condition = x_mod < stripe_mod_threshold
# combined_mask = np.logical_and(inside_circle, stripe_condition)
circle_image = np.zeros((height, width), dtype=np.uint8)
circle_image[inside_circle] = 255
Image.fromarray(circle_image).save("circle.png")

# === TRIANGLES === ramp shouldnt restat at 0
ramp_period = width / 4
ramp_periodY = width / 6
ramp_values = ((x_coords % ramp_period) / ramp_period) * 255
ramp_valuesY = ((y_coords % ramp_periodY) / ramp_periodY) * 255

combined_condition = ramp_valuesY > ramp_values 
triangle = combined_condition
combined_result = np.zeros((height, width), dtype=np.uint8)
combined_result[combined_condition] = 255
Image.fromarray(combined_result).save("Triangles.png")


# === Vertical segments === ramp shouldnt restat at 0
combined_condition = dist < ramp_values 
vertical_seq = combined_condition
combined_result = np.zeros((height, width), dtype=np.uint8)
combined_result[combined_condition] = 255
Image.fromarray(combined_result).save("Vertical.png")

# === Horizontal segments === ramp shouldnt restat at 0
combined_condition = dist < ramp_valuesY 
horizontal_seq = combined_condition
combined_result = np.zeros((height, width), dtype=np.uint8)
combined_result[combined_condition] = 255
Image.fromarray(combined_result).save("Horizontal.png")

# === Frizz === 
noise_image = np.random.randint(0, 256, (height, width), dtype=np.uint8)
combined_condition = dist < noise_image 
combined_result = np.zeros((height, width), dtype=np.uint8)
combined_result[combined_condition] = 255
Image.fromarray(combined_result).save("Frizz.png")

# === Palmleaves === 
combined_condition = triangle < vertical_seq 
combined_result = np.zeros((height, width), dtype=np.uint8)
combined_result[combined_condition] = 255
Image.fromarray(combined_result).save("Palm.png")

# ===== Criss cross ===========
combined_condition = np.bitwise_xor(vertical_seq,horizontal_seq)
combined_result = np.zeros((height, width), dtype=np.uint8)
combined_result[combined_condition] = 255
Image.fromarray(combined_result).save("criss_cross.png")

# ======== Crisscross inverterd ========

combined_condition = np.logical_not( np.bitwise_xor(vertical_seq,horizontal_seq))
combined_result = np.zeros((height, width), dtype=np.uint8)
combined_result[combined_condition] = 255
Image.fromarray(combined_result).save("criss_cross_inverted.png")