#!/usr/bin/env python3
from sense_hat import SenseHat


def read_pressure():
    sense = SenseHat()
    pres = sense.get_pressure()
    print(f"{pres:.2f}")


if __name__ == "__main__":
    read_pressure()
