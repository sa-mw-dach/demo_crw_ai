import json
from flask import Flask, jsonify, request
import requests

application = Flask(__name__)


@application.route('/')
@application.route('/status')
def status():
    return jsonify({'app status': 'ok'})


@application.route('/test')
def test_prediction():

    # Send test request to model
    response = requests.post('http://licenseplate:5000/predictions', '{"data": "Cars374.png"}')
    print(response.json())

    # Return model response
    return response.json()

if __name__ == "__main__":
    application.run(host='0.0.0.0', port=8080)
