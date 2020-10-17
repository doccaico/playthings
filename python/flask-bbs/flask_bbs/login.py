# from flask_bbs.settings import admin_users
from flask import current_app
from flask_bbs import login_manager
from flask_bbs.admin.model import AdminUser
# from flask_bbs.config.DevelopmentConfig import admin_name, admin_password

# from flask_bbs.config.BBS import (
#         FLASK_BBS_ADMIN_NAME
#         FLASK_BBS_ADMIN_PASSWORD
#         )


@login_manager.user_loader
def user_loader(name):

    with current_app.app_context():
        # print(current_app.config)
        admin_users = current_app.config['FLASK_BBS_ADMIN_USERS']
        # admin_password = current_app.config['FLASK_BBS_ADMIN_PASSWORD']
        # admin_users = {admin_name: {'password': admin_password}}
    # print(admin_users)

    if name not in admin_users:
        # print("not in")
        return
    user = AdminUser()
    user.id = name
    return user

@login_manager.request_loader
def request_loader(request):
    # with current_app.app_context():
    #
    #     admin_name = current_app.config['FLASK_BBS_ADMIN_NAME']
    #     print(admin_name)
    #     print(admin_name)
    #     print(admin_name)
    #     print(admin_name)
    #     admin_password = current_app.config['FLASK_BBS_ADMIN_PASSWORD']
    #     admin_users = {admin_name: {'password': admin_password}}

    with current_app.app_context():
        admin_users = current_app.config['FLASK_BBS_ADMIN_USERS']

    name = request.form.get('name')
    if name not in admin_users:
        return
    if request.form['password'] != admin_users[name]:
        return
    user = AdminUser()
    user.id = name
    return user
