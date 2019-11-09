import sqlite3
import json

def initdb():
    conn = sqlite3.connect('financial.db')
    financial = json.load(open('finance_small.json'))

    c = conn.cursor()

    c.execute("DROP TABLE financial")
    c.execute("CREATE TABLE financial (creditor, iban, amount, date)")

    for f in financial:
        c.execute("INSERT INTO financial VALUES ('{}','{}',{},'{}')".format(f['creditor'],
                                                                            f['debtorAccountNumber'],
                                                                            f['amount'],
                                                                            f['bookingDate']))

    conn.commit()
    conn.close()
