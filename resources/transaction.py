from flask_restful import fields, marshal_with, reqparse, Resource
from .transaction_check import get_relevant_policies


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
        ta = create_transaction(args.iban, args.creditor, args.amount)
        policies = get_relevant_policies(args.creditor, null)
        return '', 200

    @marshal_with(transaction_fields)
    def get(self):
        ta = fetch_transaction()
        return ta


def create_transaction(iban, creditor, amount):
    pass

def fetch_transaction():
    url = "https://transactiongenerator.azurewebsites.net/rest/get_transactions"
    response = request.get(url)
    data = response.json()
    return data
