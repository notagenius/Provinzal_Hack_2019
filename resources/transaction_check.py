from sqlite3 import Cursor


def get_relevant_policies(creditor, cursor: Cursor):
    # TODO needs actual database structure
    if not cursor:
        return []
    return cursor.execute(f"SELECT name FROM Insurances WHERE {creditor} in transactions_keywords")


