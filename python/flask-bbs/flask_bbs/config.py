import os


class Config(object):
    DEBUG = False
    DEPLOYMENT = False
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SECRET_KEY = '1234567890'

    # admin theme https://bootswatch.com/
    # FLASK_ADMIN_SWATCH = 'cerulean'
    FLASK_ADMIN_SWATCH = 'cosmo'

    # admin password
    FLASK_BBS_ADMIN_USERS = {
            'admin': '0000',
            'test' : 'test',
            }

class ProductionConfig(Config):
    DEBUG = False
    SQLALCHEMY_DATABASE_URI = os.environ.get('SQLALCHEMY_DATABASE_URI')

class StagingConfig(Config):
    DEVELOPMENT = True
    DEBUG = True

class DevelopmentConfig(Config):
    DEVELOPMENT = True
    DEBUG = True
    SQLALCHEMY_DATABASE_URI = "postgresql:///flask_bbs_db"

class TestingConfig(Config):
    TESTING = True
