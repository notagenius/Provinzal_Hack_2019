import requests
class Types:

    def __init__(self):
        self.transaction_types = dict()

    def setTypes(self):
        url = 'https://transactiongenerator.azurewebsites.net/rest/insurance_types/'
        response = requests.get(url)
        data = response.json()
        self.transaction_types = data
        print(data)

    def getTypes(self):
        return self.transaction_types
