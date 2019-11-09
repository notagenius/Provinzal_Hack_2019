from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    return "{\"amount\": 35.23, \"creditor\": \"test\"}"

if __name__ == '__main__':
    app.run(debug=True)
