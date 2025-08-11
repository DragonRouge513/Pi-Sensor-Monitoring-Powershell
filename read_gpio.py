#!/usr/bin/env python3

import RPi.GPIO as GPIO


def read_all_gpio_pins():
    """
    Reads the status of all GPIO pins (BCM 2-27).
    Returns:
        dict: A dictionary with pin numbers as keys and their status (HIGH/LOW) as values.
    """
    GPIO.setmode(GPIO.BCM)
    pin_values = {}
    for pin in range(2, 28):
        GPIO.setup(pin, GPIO.IN)
        pin_values[pin] = GPIO.input(pin)
    GPIO.cleanup()
    return pin_values


def read_gpio_pin(pin):
    """
    Reads the status of a specific GPIO pin.
    Args:
        pin (int): The GPIO pin number.
    Returns:
        int: The status of the pin (HIGH/LOW).
    """
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(pin, GPIO.IN)
    value = GPIO.input(pin)
    GPIO.cleanup()
    return value


# if __name__ == "__main__":
    print("All GPIO pins:", read_all_gpio_pins())
    pin = 4  # Example pin
    print(f"GPIO pin {pin}:", read_gpio_pin(pin))
