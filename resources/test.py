from flask_restful import fields, marshal_with, reqparse, Resource
import sqlite3

class Test(Resource):

    @marshal_with(transaction_fields)
    def get(self):

        conn = sqlite3.connect('financial.db')
        c = conn.cursor()
        out = next(c.execute('SELECT * FROM financial ORDER BY amount'))
        conn.close()

        return out
