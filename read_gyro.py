#!/usr/bin/env python3

from sense_hat import SenseHat

sense = SenseHat()
gyro = sense.get_gyroscope_raw()
# Calculate heading in degrees
# heading = sense.get_compass()
print(f"{gyro['x']} {gyro['y']} {gyro['z']}")
