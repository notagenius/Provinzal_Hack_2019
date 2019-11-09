from collections import namedtuple, defaultdict
from flask import Flask
from flask_restful import Resource, Api, reqparse
from apscheduler.scheduler import Scheduler
import time
import atexit
from createdb import initdb

from resources.transaction import Transaction
from Transaction_Types import Types


app = Flask(__name__)
api = Api(app)
sched = Scheduler() # Scheduler object
sched.start()

database = []
types = Types()


def get_relevant_policies(creditor, types):
    result = []
    for insurance in types:
        if insurance["creditor_keyword"] == creditor:
            result.append(insurance)
    return {x["name"] for x in result}


def find_relevant_transactions(db):  # TODO misleading name
    result = []
    for entry in db:
        # what qualifies an interesting entry?
        pols = get_relevant_policies(entry['creditor'], db)
        result.add((entry['iban'], pol) for pol in pols)
    return result  # list of tuples (iban, policy_name)
    

def startup():
    print("do once")
    #do once:
    global database
    database = initdb()
    types.setTypes()
    #-get types /rest/insurance_types an TransactionGenerator
	#https://transactiongenerator.azurewebsites.net/restexplorer.html


def do_Stuff():
	print("every second")
	types.getTypes()
	return
	#do every time:
	#-get new transactions from the TransactionsGenerator and put them to the others
	#-evaluate data and create a suggestion list
	#-sent suggestion list to frontend


sched.add_interval_job(do_Stuff,seconds=1)

startup()

api.add_resource(Transaction, '/transactions')

@app.route('/test')
def get():

    lowmount = 0
    bets_i = 0
    ix = 0

    for entr in database:
        if entr['amount'] < lowmount:
            lowmount = entr['amount']
            bets_i = ix
        ix += 1

    return str(database[bets_i])

if __name__ == "__main__":
    #startup()
    app.run()
