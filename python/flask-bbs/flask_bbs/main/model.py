import datetime
from flask_login import UserMixin

from flask_bbs.database import db

class AdminUser(UserMixin):
    pass

class Entry(db.Model):
    __tablename__ = "entries"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String, nullable=False)
    text = db.Column(db.String, nullable=False)
    mail = db.Column(db.String, nullable=False)
    password = db.Column(db.String(8))
    age = db.Column(db.String, nullable=False)
    area = db.Column(db.Integer, nullable=False)
    gender = db.Column(db.Integer, nullable=False)
    created_on = db.Column(db.DateTime(), nullable=False,
            default=datetime.datetime.now)
