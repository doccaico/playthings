import os

from flask import Flask, render_template
from flask_login import LoginManager
from flask_admin import Admin

from flask_bbs.database import db
from flask_bbs.main.view import main
from flask_bbs.main.model import Entry
from flask_bbs.admin.view import MyModelView, MyAdminIndexView


login_manager = LoginManager()
# import after created login_manager
import flask_bbs.login


# 404 page
def page_not_found(e):
  return render_template('404.html'), 404


def create_app(config=None):

    # main
    app = Flask(__name__, instance_relative_config=True)

    app.config.from_object(os.environ['APP_SETTINGS'])
    app.secret_key = os.environ.get('SECRET_KEY', app.config['SECRET_KEY'])

    app.register_error_handler(404, page_not_found)
    app.register_blueprint(main)

    # db
    db.init_app(app)

    # admin
    admin = Admin(name='BBS (admin)',
            template_mode='bootstrap3',
            index_view=MyAdminIndexView(),
            base_template='admin_base.html')
    admin.init_app(app)
    admin.add_view(MyModelView(Entry, db.session))

    # login
    login_manager.init_app(app)

    return app
