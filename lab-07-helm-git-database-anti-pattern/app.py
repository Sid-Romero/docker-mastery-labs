import os
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    message = os.environ.get('MESSAGE', 'Hello, World!')
    return f'<h1>{message}</h1>'

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
