#!/usr/bin/python

import sys
from sympy import symbols, Function, init_printing, latex

x, y, z, t = symbols("x y z t")
k, m, n = symbols("k m n", integer=True)
f, g, h = symbols("f g h", cls=Function)
init_printing()
print(
    eval(
        "latex("
        + sys.argv[1]
        .replace("\\", "")
        .replace("^", "**")
        .replace("{", "(")
        .replace("}", ")")
        + ")"
    )
)
