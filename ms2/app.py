from flask import Flask, request, jsonify
import threading, time, solver, database

app = Flask(__name__)

lock = threading.Lock()
info = []
facts = ""
collecting = False

def parse_solution(solution: str) -> list:
    appointments = []
    for s in solution:
        if s.startswith("appointment"):
            parts = s.split(",")
            appointment = {
                "patient": int(parts[1].split("(")[1]),
                "clinic": int(parts[2]),
                "doctor": int(parts[3]),
                "visit": int(parts[4]),
                "time": int(parts[5].split(")")[0])
            }
            appointments.append(appointment)
    return appointments

def create_facts(data: list) -> str:
    new_facts = dict()
    new_facts["clinics"] = set()
    new_facts["budget"] = set()
    new_facts["accessibile"] = set()
    new_facts["doctors"] = set()
    new_facts["doctor_experience"] = set()
    new_facts["visit_type"] = set()
    new_facts["requested_sessions"] = set()
    new_facts["intervallo_sedute"] = set()
    new_facts["environmental_condition"] = set()
    new_facts["cronic_visit_cost"] = set()
    new_facts["distance"] = set()
    new_facts["availability"] = set()
    new_facts["session_interval"] = set()


    for item in data:
        new_facts["clinics"].add(f'\tclinic(c{str(item["clinic_id"])},"{item["clinic_name"]}").\n')
        new_facts["budget"].add(f'\tbudget(c{str(item["clinic_id"])},{str(int(item["clinic_budget"]))}).\n')
        new_facts["requested_sessions"].add(f'\trequested_sessions(v{str(item["visit_id"])}, {str(item["visit_sessions_requests"])}).\n')
        new_facts["visit_type"].add(f'\tvisit_type(v{str(item["visit_id"])}, "{str(item["visit_type"])}", "{str(item["visit_name"])}", {str(item["visit_is_chronic"])}, {str(item["visit_on_site"])}, {str(item["visit_in_presence"])}).\n')
        new_facts["distance"].add(f'\tdistance(p{str(item["patient_id"])}, c{str(item["clinic_id"])}, {str(int(item["distance_km"]))}).\n')
        new_facts["availability"].add(f'\tavailability(c{str(item["clinic_id"])} ,d{str(item["doctor_id"])}, v{str(item["visit_id"])}, {str(int(item["visit_schedule"]))}).\n')
        new_facts["doctors"].add(f'\tdoctor(d{str(item["doctor_id"])}, "{item["doctor_name"]}", "{item["doctor_surname"]}", {str(item["doctor_age"])}, "{item["doctor_residence"]}", "{item["doctor_specialization"]}").\n')
        new_facts["doctor_experience"].add(f'\tdoctor_experience(d{str(item["doctor_id"])}, "{item["doctor_exceprience_type"]}", {str(int(item["years_of_experience"]))}).\n')
        new_facts["environmental_condition"].add(f'\tenvironmental_condition(c{str(item["clinic_id"])}, "{item["environmental_condition_type"]}", {str(int(item["environmental_condition_level"]))}, {str(int(item["condition_start"]))}, {str(int(item["condition_end"]))}).\n')
        new_facts["session_interval"].add(f'\tsession_interval(v{str(item["visit_id"])}, {str(int(item["visit_min_session_interval"]))}, {str(int(item["visit_max_session_interval"]))}).\n')

        if item["clinic_accessibility"] == 1:
            new_facts["accessibile"].add(f'\taccessibile(c{str(item["clinic_id"])}).\n')
        if item["visit_is_chronic"] == 1:
            new_facts["chronic_visit_cost"].add(f'\tchronic_visit_cost(v{str(item["visit_id"])}, {str(int(item["visit_cost"]))}).\n')

    result = ""
    for key, values in new_facts.items():
        for value in values:
            result += value

    return result

def collect_and_solve():
    global facts, collecting, info
    collecting = True
    time.sleep(60)
    with lock:
        facts_to_solve = facts
        current_timestamp = str(int(time.time()))
        facts_to_solve += 'current_time(' + current_timestamp + ').\n'
        raw_facts = []
        for data in info:
            raw_facts.append(database.next_upcoming_appointments(data["request"]["patient_id"], data["request"]["visit_id"]))
        collecting = False
        facts = ""
        info = []
    if facts_to_solve:
        facts_to_solve+=create_facts(raw_facts)
        res = solver.solve(facts_to_solve)
        if "solution" in res.keys():
            solution = parse_solution(res["solution"])
            database.insert_appointments(solution)
        return res



@app.route('/api/solve', methods=['POST'])
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
        info.append(data)
    return jsonify({"message": "fact added"}), 200
@app.route('/remove_apointment', methods=['POST'])

def remove_apointment():
    data = request.get_json()
    appointment_id = data.get('appointment_id', None)
    if appointment_id is None:
        return jsonify({"error": "No appointment ID provided"}), 400
    database.remove_appointment(appointment_id)

    return jsonify({"message": "fact removed"}), 200

if __name__ == '__main__':
    app.run(debug=True, port=5001)
