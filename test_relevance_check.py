import unittest
from Transaction_Types import Types
from createdb import initdb
import itertools as it

types = Types()
types.setTypes()
data = types.getTypes()
db = initdb()


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
    for entry in it.islice(db, 0, 10):
        pols = get_relevant_policies(entry['creditor'], types.getTypes())
        print(entry['creditor'], pols)
        result += [(entry['iban'], pol) for pol in pols]
    return result  # list of tuples (iban, policy_name)


print(get_relevant_policies("Telekom", data))
print(find_relevant_transactions(db))
#assert tuple(get_relevant_policies("Telekom", data)) == ("Berufsunfähigkeitsversicherung",)
