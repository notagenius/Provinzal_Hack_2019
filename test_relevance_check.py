import unittest
from Transaction_Types import Types


types = Types()
types.setTypes()
data = types.getTypes()


def get_relevant_policies(creditor, types):
    result = []
    for insurance in types:
        if insurance["creditor_keyword"] == creditor:
            result.append(insurance)
    return {x["insurance_type"] for x in result}


#assert tuple(get_relevant_policies("Telekom", data)) == ("Berufsunfähigkeitsversicherung",)
