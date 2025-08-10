#!/usr/bin/env python3

"""
Module to read and display temperature from the Raspberry Pi Sense HAT.
"""
from sense_hat import SenseHat


def read_humidity():
    """
    Reads the current temperature from
    the Raspberry Pi Sense HAT and prints it.
    """
    sense = SenseHat()
    hum = sense.get_humidity()
    # Sense HAT temperature can be affected by CPU heat;
    # consider calibration if needed
    print(f"{hum:.2f}")


if __name__ == "__main__":
    read_humidity()
