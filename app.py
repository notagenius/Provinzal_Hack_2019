from collections import namedtuple, defaultdict
from flask import Flask
from flask_restful import Resource, Api, reqparse
from apscheduler.scheduler import Scheduler
import time
import atexit
from createdb import initdb
import requests

from resources.transaction import Transaction
from Transaction_Types import Types


app = Flask(__name__)
api = Api(app)
sched = Scheduler() # Scheduler object
sched.start()

database = []
types = Types()
transactions = Transaction()


def is_creditor_match(creditor, creditor_keyword):
    creditor = creditor.lower()
    creditor_keyword = creditor_keyword.lower()
    return creditor_keyword in creditor


def get_relevant_policies(creditor, types):
    result = []
    for insurance in types:
        if is_creditor_match(creditor, insurance["creditor_keyword"]):
            result.append(insurance)
    return {x["insurance_type"] for x in result}


def find_relevant_transactions(db):  # TODO misleading name
    result = []
    for entry in db:
        pols = get_relevant_policies(entry['creditor'], types.getTypes())
        result += [(entry['iban'], pol) for pol in pols]
    return result  # list of tuples (iban, policy_name)


def startup():
    global database
    database = initdb()
    types.setTypes()
    #-get types /rest/insurance_types an TransactionGenerator
	#https://transactiongenerator.azurewebsites.net/restexplorer.html


def do_Stuff():
	types.getTypes()
	new_Transactions = transactions.fetch_transaction()
	suggestions = find_relevant_transactions(database)
	#suggestions = {"insurance_type": "Hausratversicherung"}
	print(suggestions)
	r = requests.post(url = "https://transactiongenerator.azurewebsites.net/rest/submit_recomendations/", data = suggestions)
	return
	#do every time:
	#-get new transactions from the TransactionsGenerator and put them to the others
	#-evaluate data and create a suggestion list
	#-sent suggestion list to frontend


sched.add_interval_job(do_Stuff,seconds=5)

startup()

api.add_resource(Transaction, '/transactions')

@app.route('/test')
def get():
    return str(find_relevant_transactions(database))

if __name__ == "__main__":
    startup()
    app.run()
