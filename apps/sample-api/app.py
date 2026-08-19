from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/")
def index():
    return jsonify(service="sample-api", status="ok")


@app.get("/healthz")
def healthz():
    return jsonify(status="ok")
