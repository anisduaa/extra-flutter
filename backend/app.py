from flask import Flask, request, jsonify, g
import sqlite3
from util import detect_license_plate
from flask_cors import CORS
import os

app = Flask(__name__)
CORS(app)

DATABASE = 'database.db'

def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = sqlite3.connect(DATABASE)
    return db

@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()

def init_db():
    if not os.path.exists(DATABASE):
        db = get_db()
        cursor = db.cursor()
        cursor.execute('''CREATE TABLE IF NOT EXISTS cars (
                            id INTEGER PRIMARY KEY AUTOINCREMENT,
                            plate_number TEXT NOT NULL UNIQUE,
                            details TEXT NOT NULL
                        )''')
        db.commit()
        print("Database and table created successfully.")
    else:
        print("Database already exists.")

@app.route('/api/save', methods=['POST'])
def save_plate():
    data = request.json
    plate_number = data['plate_number']
    details = data['details']

    db = get_db()
    cursor = db.cursor()
    cursor.execute("INSERT INTO cars (plate_number, details) VALUES (?, ?)", (plate_number, details))
    db.commit()

    return jsonify({"message": "Data saved successfully!"})

@app.route('/api/match', methods=['POST'])
def match_plate():
    data = request.json
    plate_number = data['plate_number']

    db = get_db()
    cursor = db.cursor()
    cursor.execute("SELECT details FROM cars WHERE plate_number = ?", (plate_number,))
    car = cursor.fetchone()

    if car:
        return jsonify({"match": True, "details": car[0]})
    else:
        return jsonify({"match": False, "message": "Car not found."})

@app.route('/api/detect', methods=['POST'])
def detect_plate():
    file = request.files['image']
    img_bytes = file.read()

    # Use the model to detect the license plate
    plate_number = detect_license_plate(img_bytes)

    return jsonify({"plate_number": plate_number})

if __name__ == '__main__':
    with app.app_context():
        init_db()
    app.run(debug=True)
