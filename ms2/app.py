from flask import Flask, request, jsonify
import threading, time, solver

app = Flask(__name__)

lock = threading.Lock()
facts = []
collecting = False


def collect_and_solve():
    global facts, collecting

    collecting = True
    time.sleep(60)

    with lock:
        facts_to_solve = facts
        current_timestamp = str(time.time())
        facts_to_solve += ['current_time(' + current_timestamp + ').']
        collecting = False
        facts = []

    if facts_to_solve:
        # query sul db per le info
        res = solver.solve(facts_to_solve)
        return res



@app.route('/solve', methods=['POST'])
def solve():
    global collecting, facts

    data = request.get_json()
    new_facts = data.get('facts', None)
    if new_facts is None:
        return jsonify({"error": "No fact provided"}), 400

    with lock:
        if not collecting:
            threading.Thread(target=collect_and_solve).start()
        facts += new_facts

    return jsonify({"message": "fact added"}), 200
# {
#   "status": "200 OK",
#   "message": "Richiesta ricevuta. Elaborazione in corso."
# }



if __name__ == '__main__':
    app.run(debug=True, port=5001)
