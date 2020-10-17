import itertools


# s1 = set(("v","e", "T", "n", "A", "E", "t", "b"))
# remove: A e t
# s1 = set(("v","T", "n", "E", "t", "b"))
s1 = set(("v","T", "n", "E", "t", "b", "s"))


# box = set(itertools.product(s1,s1,s1))
# box = set(itertools.product(s1,s1,s1,s1,s1,
#     s1,s1,s1))
# box = set(itertools.product(s1,s1,s1,s1,s1,
#     s1))
box = set(itertools.product(s1,s1,s1,s1,s1,
    s1,s1))

ret = []
for v in box:
    l = list(set(v))
    s = 'go "$target" "-'
    for i in l:
        s += i
    s += '"'
    ret.append(s)

for cmd in set(ret):
    print(cmd)
