#!/usr/bin/env python3

from sense_hat import SenseHat

sense = SenseHat()
mag = sense.get_compass_raw()
# Calculate heading in degrees
# heading = sense.get_compass()
print(f"{mag['x']} {mag['y']} {mag['z']}")
