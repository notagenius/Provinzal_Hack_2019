from flask_restful import fields, marshal_with, reqparse, Resource

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
    @marshal_with(transaction_fields)
    def post(self):
        args = parser.parse_args()
        ta = create_transaction(args.iban, args.creditor, args.amount)
        return ta

    @marshal_with(transaction_fields)
    def get(self):
        args = parser.parse_args()
        ta = fetch_transaction()
        return ta


def create_transaction(iban, creditor, amount):
    pass

def fetch_transaction():
    #TODO dummy
    return {'amount': 50.0, 'creditor': 'Creditor', 'iban': 'DE1029...'}
