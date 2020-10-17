import csv
import ast
import datetime
import random

name = []
mail = []

with open('name_mail.csv') as f:
    reader = csv.reader(f)
    for l in reader:
        name.append(l[0])
        mail.append(l[1])

dt1 = datetime.datetime.now()
i = 0
ret = []

with open('ka_data.csv') as f:
    reader = csv.reader(f)
    reader = list(reader)[52:]
    random.shuffle(reader)

    for row in reader:
        s = ast.literal_eval(row[9])
        L = []
        L.append(i+1)
        L.append(name[i])
        L.append("{} : {} \n {} : {}".format(s[0][0], s[0][1], s[1][0], s[1][1]))
        L.append(mail[i])
        L.append('0000')
        L.append(random.randint(18, 50))
        L.append(random.randint(0, 46))
        L.append(random.randint(0, 3))
        L.append(dt1 + datetime.timedelta(seconds=i))
        i += 1
        ret.append(L)

with open('test.csv', 'w') as f:
    writer = csv.writer(f)
    writer.writerows(ret)
