import sqlite3
import json
import os


def initdb():

    try:
        os.remove('financial.db')
    except:
        pass

    conn = sqlite3.connect('financial.db')
    financial = json.load(open('finance_small.json'))

    c = conn.cursor()
    
    #try:
    #    c.execute("DROP TABLE financial")
    #except:
    #    pass
    c.execute("CREATE TABLE financial (creditor, iban, amount, date)")

    for f in financial:
        c.execute("INSERT INTO financial VALUES ('{}','{}',{},'{}')".format(f['creditor'],
                                                                            f['debtorAccountNumber'],
                                                                            f['amount'],
                                                                            f['bookingDate']))

    conn.commit()
    conn.close()
