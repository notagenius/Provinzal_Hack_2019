from collections import namedtuple, defaultdict
from flask import Flask
from flask_restful import Resource, Api, reqparse
from apscheduler.scheduler import Scheduler
import time
import atexit
from createdb import initdb

from resources.transaction import Transaction
from resources.test import Test



app = Flask(__name__)
api = Api(app)
sched = Scheduler() # Scheduler object
sched.start()


def startup():
	print("do once")
	#do once:
    initdb()
	#-get types /rest/insurance_types an TransactionGenerator
	#https://transactiongenerator.azurewebsites.net/restexplorer.html

def do_Stuff():
	print("every second")
	return
	#do every time:
	#-get new transactions from the TransactionsGenerator and put them to the others
	#-evaluate data and create a suggestion list
	#-sent suggestion list to frontend


	

sched.add_interval_job(do_Stuff,seconds=1)




api.add_resource(Transaction, '/transactions')
api.add_resource(Test, '/test')

if __name__ == "__main__":
    startup()
    app.run()
