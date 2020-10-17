# url: https://esolangs.org/wiki/Brainfuck#Hello.2C_World.21
# expected: Hello, World!

# Short program printing Hello, World! by primo
# from http://codegolf.stackexchange.com/a/68494/6691.
# This program needs four cells to the left of the starting point
# (so standard scoring would give it an adjustment of four instructions and four ticks)
# and requires wrapping byte sized cells.

--<-<<+[+[<+>--->->->-<<<]>]<<--.<++++++.<<-..<<.<+.>>.>>.<<<.+++.>>.>>-.<<<+.
