import os

from smtplib import SMTP
from email.mime.text import MIMEText
from email.header import Header

from flask_bbs.menu import AREA, GENDER


# Gmailを使ったメール送信
#
# :使い方:

# Gmailアカウントで「安全性の低いアプリのアクセス」を許可
# https://myaccount.google.com/security


def send(gmail_address, gmail_password,
        name, text, frommail, tomail, age, area, gender):

    charset = 'iso-2022-jp'

    to = tomail # 送信先メールアドレス
    sub = 'BBS' # メール件名
    body = text # メール本文
    host = 'smtp.gmail.com'
    port = 587

    body = '''
    【名前】{}
    【年齢】{}
    【性別】{}
    【住み】{}
    【メール】{}

     --------------------------

    {}
    '''.format(name, age, GENDER[gender], AREA[area], frommail, text)
    msg = MIMEText(body)
    msg['Subject'] = "{} 様からメールが届きました".format(name)
    msg['From'] = Header('BBS - メル友募集 -'.encode(charset),charset).encode()
    msg['To'] = to

    srv=SMTP("smtp.gmail.com", 587)
    srv.ehlo()
    srv.starttls()
    srv.login(gmail_address, gmail_password)
    srv.send_message(msg)
    srv.quit()

if __name__ == '__main__':
    frommail = "exsample@gmail.com"
    tomail = "exsample@yahoo.co.jp"
    gmail_address = os.environ['FLASK_BBS_GMAIL_ADDRESS']
    gmail_password = os.environ['FLASK_BBS_GMAIL_PASSWORD']
    send(
            gmail_address,
            gmail_password,
            "山田一郎",
            "こんにちわ。届いていますか？",
            frommail,
            tomail,
            "99",
            "東京",
            "男",
            )
