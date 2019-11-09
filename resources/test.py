from flask_restful import fields, marshal_with, reqparse, Resource
import sqlite3

class Test(Resource):

    def get(self, db):

        lowmount = 0
        ix = 0
    
        for entr in db:
            if entr['amount'] < lowmount:
                lowmount = entr['amount']
                ix += 1

        return db[ix]
