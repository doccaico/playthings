from flask import current_app
from flask_admin import expose, AdminIndexView
from flask_admin.contrib import sqla
from flask_login import login_user, logout_user, current_user
from flask import url_for, request, redirect

from flask_bbs.admin.model import AdminUser
from flask_bbs.menu import AREA, GENDER
from flask_bbs.main.model import Entry


SNIPET_LENGTH = 100

def fmt_text(text):
    if len(text) >= SNIPET_LENGTH:
        return text[:SNIPET_LENGTH][:SNIPET_LENGTH] + '...'
    return text

class MyModelView(sqla.ModelView):

    can_edit = False

    # order by id (DESC)
    column_default_sort = ('id', True)

    column_list = (
            Entry.id,
            Entry.name,
            Entry.text,
            # Entry.mail,
            # Entry.password,
            Entry.age,
            Entry.area,
            Entry.gender,
            Entry.created_on
            )

    column_formatters = dict(
            area=lambda v,c,m,p: AREA[m.area],
            gender=lambda v,c,m,p: GENDER[m.gender],
            text=lambda v,c,m,p: fmt_text(m.text),
            created_on=lambda v,c,m,p: str(m.created_on)[:19],
            )

    def is_accessible(self):
        return current_user.is_authenticated

class MyAdminIndexView(AdminIndexView):

    @expose('/')
    def index(self):
        if not current_user.is_authenticated:
            return redirect(url_for('.login_view'))
        return redirect('/')

    @expose('/login/', methods=('GET', 'POST'))
    def login_view(self):

        if (request.method == "POST"):

            name = request.form["name"]
            password = request.form['password']

            with current_app.app_context():
                admin_users = current_app.config['FLASK_BBS_ADMIN_USERS']

            if name in admin_users and password == admin_users[name]:
                user = AdminUser()
                user.id = name
                login_user(user)
            else:
                return self.render('/login.html', wrong="true")

        if current_user.is_authenticated:
            return redirect('/admin/entry')

        return self.render('/login.html', current_user=current_user)

    @expose('/logout/')
    def logout_view(self):
        logout_user()
        return redirect(url_for('main.index'))
