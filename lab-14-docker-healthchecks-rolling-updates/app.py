from flask import Flask
import os
import time

app = Flask(__name__)

healthy = True

@app.route('/')
def hello_world():
    return 'Hello, World!\n'

@app.route('/health')
def health_check():
    global healthy
    if healthy:
        return 'OK', 200
    else:
        return 'Unhealthy', 500

@app.route('/break')
def break_app():
    global healthy
    healthy = False
    return 'Application marked as unhealthy', 200

@app.route('/fix')
def fix_app():
    global healthy
    healthy = True
    return 'Application marked as healthy', 200

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=False, host='0.0.0.0', port=port)