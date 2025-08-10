#!/usr/bin/env python3
from sense_hat import SenseHat


def read_temperature():
    sense = SenseHat()
    temp = sense.get_temperature()
    print(f"{temp:.2f}")


if __name__ == "__main__":
    read_temperature()
