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

# Simulazione di un database di utenti
credentials = {"user": "admim", "password": "password123"}


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


def create_user_facts(data: dict)-> str:
    facts = ""
    facts+= f'paziente(p{str(data["id"])},"{str(data["nome"])}","{str(data["cognome"])}","{str(data["residenza"])}").\n'
    return facts

@app.route('/api/add_request', methods=['POST'])
@jwt_required()
def add_request():
    data = request.get_json()
    if not data:
        return jsonify({'msg': 'Invalid data'}), 400
    data["paziente_id"] = get_jwt()["id"]

    facts = create_user_facts(get_jwt())
    response = requests.post('http://localhost:5001/solve', json={"facts": facts, "request": data})
    if response.status_code == 200:
        return response.json()
    else:
        return {'msg': 'Errore durante la creazione della richiesta'}, 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)
