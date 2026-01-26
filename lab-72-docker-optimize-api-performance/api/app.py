from flask import Flask
import time
import os

app = Flask(__name__)

@app.route('/')
def hello_world():
    # Simulate some processing time
    time.sleep(0.1)  # 100ms delay
    return 'Hello, World! This is a containerized API!\n'

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
