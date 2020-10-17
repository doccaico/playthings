import os

from flask import url_for, render_template, request, redirect, Blueprint
from flask_paginate import Pagination, get_page_parameter
from flask import current_app

from flask_bbs.database import db
from flask_bbs.main.model import Entry
from flask_bbs.menu import AREA, GENDER
from flask_bbs.email import gmail


main = Blueprint('main', __name__)

@main.route('/', methods=['GET', 'POST'])
def index():

    if request.method == "POST":
        id = request.form['id']
        password = request.form['password']
        entry = Entry.query.filter(Entry.id == id).first()
        if (entry):
            name = entry.name
            if entry.password == password:
                msg = "投稿は削除されました"
                db.session.delete(entry)
                db.session.commit()
            else:
                msg = "パスワードが間違っています"
        else:
            name = ""
            msg = "投稿者IDが見つかりませんでした"
        return render_template('delete_result.html', id=id, name=name, msg=msg)

    search = False
    q = request.args.get('q')
    if q:
        search = True

    per_page = 5
    page = request.args.get(get_page_parameter(), type=int, default=1)

    entries = Entry.query.order_by(Entry.id.desc())

    pagination = Pagination(page=page, total=entries.count(), search=search, per_page=per_page)

    entries = entries.limit(per_page).offset(per_page * (page-1)).all()

    for i, entry in enumerate(entries):
        entries[i].area = AREA[entry.area]
        entries[i].gender = GENDER[entry.gender]
    return render_template('index.html', entries=entries, pagination=pagination)

@main.route('/new', methods=['GET', 'POST'])
def new():

    if request.method == "POST":
        db.session.add(Entry(
                    name=request.form['name'],
                    text=request.form['text'],
                    mail=request.form['mail'],
                    password=request.form['password'],
                    age=request.form['age'],
                    area=request.form['area'],
                    gender=request.form['gender'],
                    ))

        db.session.commit()
        return redirect(url_for('main.index'))

    return render_template('new.html', areaes=AREA, gender=GENDER)

@main.route('/send/<int:post_id>', methods=['GET', 'POST'])
def send(post_id):

    name = '[{}] {}'.format(
            post_id, Entry.query.filter(Entry.id == post_id).first().name)
    print(name)

    if request.method == "POST":

        gmail_address = os.environ['FLASK_BBS_GMAIL_ADDRESS']
        gmail_password = os.environ['FLASK_BBS_GMAIL_PASSWORD']
        try:
            gmail.send(
                    gmail_address,
                    gmail_password,
                    request.form['name'],
                    request.form['text'],
                    request.form['mail'],
                    Entry.query.filter(Entry.id == post_id).first().mail,
                    request.form['age'],
                    request.form['area'],
                    request.form['gender'],
                    )
            msg = "{}さんへメールを送信しました".format(name)
        except:
            msg = "上限に達したのでメールを送信できませんでした"

        return render_template('send_result.html', msg=msg)

    return render_template('send.html', name=name,
            areaes=AREA, gender=GENDER)
