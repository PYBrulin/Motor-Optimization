import math
import os

os.system("color")

COLOR_OUTPUT = True
CEND = "\33[0m"
CRED = "\33[31m"
CGREEN = "\33[32m"
CBLUE = "\33[34m"

# Colored output
if COLOR_OUTPUT:
    colortable = {
        "A": CRED + "A" + CEND,
        "B": CBLUE + "B" + CEND,
        "C": CGREEN + "C" + CEND,
        "a": CRED + "a" + CEND,
        "b": CBLUE + "b" + CEND,
        "c": CGREEN + "c" + CEND,
        "-": CRED + "-" + CEND,
        "+": CBLUE + "+" + CEND,
    }
else:
    colortable = {
        "A": "A",
        "B": "B",
        "C": "C",
        "a": "a",
        "b": "b",
        "c": "c",
        "-": "-",
        "+": "+",
    }


def repeats(string):
    """Find repeated substring in string
    https://stackoverflow.com/a/41077376"""
    for x in range(1, len(string)):
        substring = string[:x]
        if (
            substring * (len(string) // len(substring))
            + (substring[: len(string) % len(substring)])
            == string
        ):
            return substring
    return string  # Nothing


def winding_scheme(N: int, P: int) -> str:
    """Follows the calculation as explained at
    https://www.bavaria-direct.co.za/scheme/calculator/
    https://maltemedia.de/brushless/wicklungsschema/
    """

    if N % 3 != 0 or N < 3:
        return "Number of slots must be divisible by 3!"

    if P % 2 != 0 or P < 2:
        return "Number of poles must be even!"

    if P == N:
        return "Number of poles must be unequal to number of slots!"

    angle = 180 * P / N
    a, b, c = 0, 0, 0
    A, B, C = 0, 0, 0
    schema = ""
    sum = 0.0

    for _ in range(N):

        if sum >= 330 or sum < 30:
            schema += "A"
            A += 1

        if sum >= 30 and sum < 90:
            schema += "b"
            b += 1

        if sum >= 90 and sum < 150:
            schema += "C"
            C += 1

        if sum >= 150 and sum < 210:
            schema += "a"
            a += 1

        if sum >= 210 and sum < 270:
            schema += "B"
            B += 1

        if sum >= 270 and sum < 330:
            schema += "c"
            c += 1

        sum = (sum + angle) % 360

    if a == b and a == c and A == B and A == C:
        while schema[len(schema) - 1] == "a" or schema[len(schema) - 1] == "A":
            schema = schema[-1] + schema[0:-1]

        if schema[0] == "a":
            schema = schema.replace("a", "x")
            schema = schema.replace("b", "y")
            schema = schema.replace("c", "z")
            schema = schema.replace("A", "a")
            schema = schema.replace("B", "b")
            schema = schema.replace("C", "c")
            schema = schema.replace("x", "A")
            schema = schema.replace("y", "B")
            schema = schema.replace("z", "C")

        if (schema.count("B") + schema.count("b")) > (
            schema.count("C") + schema.count("c")
        ):
            schema = schema.replace("b", "x")
            schema = schema.replace("c", "y")
            schema = schema.replace("x", "c")
            schema = schema.replace("y", "b")
            schema = schema.replace("B", "x")
            schema = schema.replace("C", "y")
            schema = schema.replace("x", "C")
            schema = schema.replace("y", "B")

    x = "abcABC"
    y = "---+++"
    dirtable = schema.maketrans(x, y)
    coildir = schema.translate(dirtable)

    output = "{}N{}P Configuration:".format(
        N,
        P,
    )

    output += "\n\t{} cogging steps per turn".format(
        math.lcm(N, P),
    )

    output += "\nWinding:\n\t({})\n\t({})".format(
        "".join([colortable[_] for _ in schema]),
        "".join([colortable[_] for _ in coildir]),
    )

    coiltable = {"A": "Aa", "B": "Bb", "C": "Cc", "a": "aA", "b": "bB", "c": "cC"}
    schema = "".join([coiltable[_] for _ in schema])
    coildir = schema.translate(dirtable)

    output += (
        "\nFull-coil Winding :\n\t"
        + "({}) / Repeats ({}) {} times\n\t".format(
            "".join([colortable[_] for _ in schema]),
            repeats("".join([colortable[_] for _ in schema])),
            "".join([colortable[_] for _ in schema]).count(
                repeats("".join([colortable[_] for _ in schema]))
            ),
        )
        + "({}) / Repeats ({}) {} times\n\t".format(
            "".join([colortable[_.upper()] for _ in schema]),
            repeats("".join([colortable[_.upper()] for _ in schema])),
            "".join([colortable[_.upper()] for _ in schema]).count(
                repeats("".join([colortable[_.upper()] for _ in schema]))
            ),
        )
        + "({}) / Repeats ({}) {} times\n".format(
            "".join([colortable[_] for _ in coildir]),
            repeats("".join([colortable[_] for _ in coildir])),
            "".join([colortable[_] for _ in coildir]).count(
                repeats("".join([colortable[_] for _ in coildir]))
            ),
        )
    )

    return output


if __name__ == "__main__":
    print(winding_scheme(3, 2))  # The simplest of all

    print(winding_scheme(6, 4))

    print("T-Motor MN2212")
    print(winding_scheme(9, 12))  # type MN2212

    print("T-Motor MN6007")
    print(winding_scheme(18, 22))  # type MN6007

    print("T-Motor MN4006")
    print(winding_scheme(18, 24))  # type MN4006

    print("T-Motor MN501-S")
    print(winding_scheme(24, 28))  # type MN501-S

    print("T-Motor U8II")
    print(winding_scheme(36, 42))  # type U8
