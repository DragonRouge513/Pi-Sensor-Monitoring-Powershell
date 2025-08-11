#!/usr/bin/env python3
from sense_hat import SenseHat

sense = SenseHat()

X = [255, 0, 0]  # Red
o = [255, 255, 255]  # White

question_mark = [
    o, o, o, X, X, o, o, o,
    o, o, X, o, o, X, o, o,
    o, o, o, o, o, X, o, o,
    o, o, o, o, X, o, o, o,
    o, o, o, X, o, o, o, o,
    o, o, o, X, o, o, o, o,
    o, o, o, o, o, o, o, o,
    o, o, o, X, o, o, o, o
]

sense.set_pixels(question_mark)
