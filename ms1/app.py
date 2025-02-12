from flask import Flask, request, jsonify
import requests
from datetime import timedelta
from flask_jwt_extended import (
    JWTManager,
    create_access_token,
    jwt_required,
    get_jwt_identity,
)


app = Flask(__name__)

# Configura la chiave segreta per i token JWT
app.config["JWT_SECRET_KEY"] = "p7mNJ7gNEX7HXGHdjcXFh7w3syh4dm&@"
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(hours=1)

jwt = JWTManager(app)

@app.route('/')
def index():
    return "Sistema di gestione degli appuntamenti con Flask e ASP!"

# Simulazione di un database di utenti
credentials = {"user": "admim", "password": "password123"}

@app.route("/api/login", methods=["POST"])
def login():
    # Recupera le credenziali dal client
    username = request.json.get("user")
    password = request.json.get("password")

    # Verifica le credenziali
    if credentials["user"] == username and credentials["password"] == password:
        # Crea un token di accesso
        access_token = create_access_token(identity=username)
        return jsonify(access_token=access_token), 200
    else:
        return jsonify({"msg": "Credenziali non valide"}), 401

@app.route("/protected", methods=["GET"])
@jwt_required()
def protected():
    # Ottieni l'identità dell'utente dal token
    current_user = get_jwt_identity()
    return jsonify(logged_in_as=current_user), 200



@app.route('/api/add_request', methods=['POST'])
@jwt_required()
def add_request():
    current_user = get_jwt_identity()
    data = request.get_json()
    response = requests.post('http://localhost:5001/solve', json=data)
    if response.status_code == 200:
        return response.json()
    else:
        return {'message': 'Errore durante la creazione della richiesta'}, 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)
