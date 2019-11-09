from collections import namedtuple, defaultdict
from flask import Flask
from flask_restful import Resource, Api, reqparse

from resources.transaction import Transaction


app = Flask(__name__)
api = Api(app)


api.add_resource(Transaction, '/transactions')

if __name__ == "__main__":
    app.run()
