#!/usr/bin/env python3
from sense_hat import SenseHat


def read_humidity():
    sense = SenseHat()
    hum = sense.get_humidity()
    print(f"{hum:.2f}")


if __name__ == "__main__":
    read_humidity()
