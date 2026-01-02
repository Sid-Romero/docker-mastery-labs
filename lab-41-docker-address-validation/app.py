from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/validate', methods=['POST'])
def validate_address():
    data = request.get_json()
    address = data.get('address')

    # Simulate validation logic (replace with real validation)
    if address:
        validation_result = {
            'address': address,
            'is_valid': True,
            'confidence': 0.95
        }
        return jsonify(validation_result), 200
    else:
        return jsonify({'error': 'Address is required'}), 400

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
