from flask import Flask, request, jsonify
import requests, database, hashlib
from datetime import timedelta
from flask_jwt_extended import (
    JWTManager,
    create_access_token,
    jwt_required,
    get_jwt_identity,
    get_jwt
)
from flask_cors import CORS


app = Flask(__name__)
CORS(app)  # permette CORS su tutte le rotte
# Configura la chiave segreta per i token JWT
app.config["JWT_SECRET_KEY"] = "p7mNJ7gNEX7HXGHdjcXFh7w3syh4dm&@"
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(hours=1)

jwt = JWTManager(app)

@app.route('/')
def index():
    return "Sistema di gestione degli appuntamenti con Flask e ASP!"

@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = hashlib.sha256(data.get('password').encode('utf-8')).hexdigest()
    print(email, password)
    if not email or not password:
        return jsonify({'msg': 'Email and password are required'}), 400
    result = database.login(email, password)
    if result:
        access_token = create_access_token(identity=data["email"], additional_claims=result)
        return jsonify(access_token=access_token), 200
    else:
        return jsonify({"msg": "Credenziali non valide!"}), 401

@app.route("/api/signin", methods=["POST"])
def signin():
    data = request.get_json()
    data["password"] = hashlib.sha256(data.get('password').encode('utf-8')).hexdigest()
    result = database.signin(data)
    if result:
        access_token = create_access_token(identity=data["email"],  additional_claims=result)
        return jsonify(access_token=access_token), 200


    return jsonify({"msg": "Paziente esistente!"}), 400

@app.route("/api/me", methods=["GET"])
@jwt_required()
def me():
    return jsonify(identity=get_jwt_identity(), claims = get_jwt()), 200


def create_initial_facts(data: dict)-> str:

    facts = "\n"
    facts += f'\tpatient(p{str(data["id"])},"{str(data["name"])}","{str(data["surname"])}","{str(data["residence"])}").\n'
    facts += f'\tneeds(p{str(data["id"])},v{str(data["visit_id"])},{str(data["urgency"])}).\n'

    if "interval_preference" in data.keys():
        MinP = str(data["interval_preference"]["min"])
        MaxP = str(data["interval_preference"]["max"])
        facts += f'\tpatient_interval(p{str(data["id"])}, v{str(data["visit_id"])}, {MinP}, {MaxP}).\n'

    if "doctor_preference" in data.keys():
        facts += f'\tdoctor_preference_effect(p{str(data["id"])}, d{str(data["doctor_preference"])}, 1).\n'

    if "clinic_preference" in data.keys():
        facts += f'\tpreference(p{str(data["id"])}, c{str(data["clinic_preference"])}).\n'

    if "generic_doctor_preferences" in data.keys():
        for preferenza in data["generic_doctor_preferences"]:
            facts += f'\tdoctor_preference(p{str(data["id"])}, "{(preferenza["doctor_type"])}", "{(preferenza["specialization"])}", {str(preferenza["experience"])}).\n'

    if "sensory_preferences" in data.keys():
        for preference in data["sensory_preferences"]:
            facts += f'\tsensory_preference(p{str(data["id"])}, "{preference}").\n'

    if "motor_difficulties" in data.keys():
        if data["motor_difficulties"]:
            facts += f'\tdisabled(p{str(data["id"])}).\n'

    if "appointment_preferences" in data.keys():
        for appointment_preferences in data["appointment_preferences"]:
            facts += f'\tappointment_preferences(p{str(data["id"])}, "{(appointment_preferences["doctor_type"])}", "{(appointment_preferences["specialization"])}", {str(appointment_preferences["experience"])}).\n'

    print("starting facts", facts)
    return facts

@app.route('/api/create_appointment', methods=['POST'])
@jwt_required()
def add_request():
    data = request.get_json()
    if not data:
        return jsonify({'msg': 'Invalid data'}), 400
    data["patient_id"] = get_jwt()["id"]

    facts = create_initial_facts(get_jwt() | data)
    data = {
        "patient_id": data["patient_id"],
        "visit_id": data["visit_id"]
    }
    response = requests.post('http://localhost:5001/api/solve', json={"facts": facts, "request": data})
    if response.status_code == 200:
        return response.json()
    else:
        return {'msg': 'Error creating request'}, 500

@app.route('/api/remove_appointment', methods=['POST'])
@jwt_required()
def remove_appointment():
    data = request.get_json()
    if not data:
        return jsonify({'msg': 'Invalid data'}), 400
    appointment_id = data.get('appointment_id')
    if not appointment_id:
        return jsonify({'msg': 'Appointment ID is required'}), 400
    response = requests.post('http://localhost:5001/api/remove_appointmet', json={"appointment_id": appointment_id})
    return response

if __name__ == '__main__':
    app.run(debug=True, port=5000)
