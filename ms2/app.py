from flask import Flask, request, jsonify
import threading, time, solver, database

app = Flask(__name__)

lock = threading.Lock()
info = []
facts = []
collecting = False

def create_facts(data: list) -> str:
    budget = set()
    clinics = set()
    accessibile = set()
    doctors = set()
    tipo_di_visita = set()
    costo_visita = set()
    sedute_richieste = set()
    intervallo_sedute = set()
    disponibilita = set()
    condizione_ambientale = set()

    x = [{'paziente_id': 11, 'paziente_nome': 'Admin', 'paziente_cognome': 'Admin', 'visita_id': 9, 'clinica_id': 22, 'clinica_nome': 'Ospedale Santa Maria', 'distanza_km': 65.99}, {'paziente_id': 11, 'paziente_nome': 'Admin', 'pazient\
    e_cognome': 'Admin', 'visita_id': 9, 'clinica_id': 4, 'clinica_nome': 'Ospedale Renzetti', 'distanza_km': 82.84}, {'paziente_id': 11, 'paziente_nome': 'Admin', 'paziente_cognome': 'Admin', 'visita_id': 9, 'clinica_id': 7, 'clin\
    ica_nome': 'Ospedale San Camillo', 'distanza_km': 86.86}, {'paziente_id': 11, 'paziente_nome': 'Admin', 'paziente_cognome': 'Admin', 'visita_id': 9, 'clinica_id': 15, 'clinica_nome': 'Ospedale Cristo Re', 'distanza_km': 92.88},
     {'paziente_id': 11, 'paziente_nome': 'Admin', 'paziente_cognome': 'Admin', 'visita_id': 9, 'clinica_id': 20, 'clinica_nome': 'Ospedale Belcolle', 'distanza_km': 108.76}, {'paziente_id': 11, 'paziente_nome': 'Admin', 'paziente_\
    cognome': 'Admin', 'visita_id': 9, 'clinica_id': 21, 'clinica_nome': 'Azienda Ospedaliera di Perugia', 'distanza_km': 118.08}, {'paziente_id': 11, 'paziente_nome': 'Admin', 'paziente_cognome': 'Admin', 'visita_id': 9, 'clinica_id': 25, 'clinica_nome': 'Ospedale di Città di Castello', 'distanza_km': 155.14}]
    facts = ""
    for item in data:
        facts += f'clinica(c{str(item["clinica_id"])},"{str(item["clinica_nome"])}").\n'
        facts += f'visita(v{str(item["visita_id"])}). \n'
        facts += f'distanza(c{str(item["clinica_id"])},v{str(item["visita_id"])},{item["distanza_km"]}).\n'
def collect_and_solve():
    global facts, collecting, info

    collecting = True
    time.sleep(60)

    with lock:
        facts_to_solve = facts
        current_timestamp = str(time.time())
        facts_to_solve += ['current_time(' + current_timestamp + ').']
        raw_facts = info
        collecting = False
        facts = []
        info = []

    if facts_to_solve:
        facts_to_solve += create_facts(raw_facts)
        res = solver.solve(facts_to_solve)
        return res



@app.route('/solve', methods=['POST'])
def solve():
    global collecting, facts, info

    data = request.get_json()
    new_facts = data.get('facts', None)
    if new_facts is None:
        return jsonify({"error": "No fact provided"}), 400

    with lock:
        if not collecting:
            threading.Thread(target=collect_and_solve).start()
        facts += new_facts
        info += database.get_pazienti_cliniche_visita(data["request"]["paziente_id"], data["request"]["visita_id"])
        print("info", info)
    return jsonify({"message": "fact added"}), 200
# {
#   "status": "200 OK",
#   "message": "Richiesta ricevuta. Elaborazione in corso."
# }



if __name__ == '__main__':
    app.run(debug=True, port=5001)
