import json
from flask import Flask, jsonify, request
from prediction import predict

application = Flask(__name__)

VERSION = 'v2'

@application.route('/')
@application.route('/status')
def status():
    return jsonify({'model status': 'ok (' + VERSION + ')'})


@application.route('/predictions', methods=['POST'])
def object_detection():
    data = request.data or '{}'
    body = json.loads(data)
    res = predict(body)
    res['model version'] = VERSION
    return jsonify(res)
