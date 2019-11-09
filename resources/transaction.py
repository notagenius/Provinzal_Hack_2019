from flask_restful import fields, marshal_with, reqparse, Resource
from .transaction_check import get_relevant_policies
import requests


parser = reqparse.RequestParser()
parser.add_argument('amount', dest='amount', required=True, type=int)
parser.add_argument('iban', dest='iban', required=True)
parser.add_argument('creditor', dest='creditor', required=True)


transaction_fields = {
    'iban': fields.String,
    'creditor': fields.String,
    'amount': fields.Float
}


class Transaction(Resource):
    
    def __init__(self):
        return
    
    def post(self):
        args = parser.parse_args()
        policies = get_relevant_policies(args.creditor, null)
        return '', 200

    @marshal_with(transaction_fields)
    def get(self):
        ta = self.fetch_transaction()
        return ta

    def fetch_transaction(self):
        url = "https://transactiongenerator.azurewebsites.net/rest/get_transactions"
        response = requests.get(url)
        data = response.json()
        return data
