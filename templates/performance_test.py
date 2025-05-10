import clingo
import time
import random
from datetime import datetime, timedelta
def on_message(msg):
    print(msg)
    # if msg.type != clingo.MessageType.Warning and msg.type != clingo.MessageType.Info:
    #     print(msg)

def solve(facts):
    ctl = clingo.Control(["--warn=none"])
    if facts == "":
        return {"message": "No fact provided"}, 400

    program = facts
    program += r"""
        sensory_penalty(Patient, Clinic, Time, Level) :- 
            patient(Patient,_,_,_), 
            clinic(Clinic,_), 
            availability(Clinic,_, VisitType, Time), 
            needs(Patient, VisitType, _), 
            sensory_preference(Patient, Type), 
            environmental_condition(Clinic, Type, Level, Start, End), 
            Time >= Start, Time <= End. 
        
        sensory_penalty(Patient, Clinic, Time, 2) :- 
            patient(Patient, _, _, _), 
            clinic(Clinic, _), 
            availability(Clinic,_, VisitType, Time), 
            needs(Patient, VisitType, _), 
            sensory_preference(Patient, Type), 
            not environmental_condition(Clinic, Type, _, _, _). 
        
        sensory_penalty(Patient, Clinic, Time, 2) :- 
            patient(Patient, _, _, _), 
            clinic(Clinic, _), 
            availability(Clinic,_, VisitType, Time), 
            needs(Patient, VisitType, _), 
            sensory_preference(Patient, Type), 
            environmental_condition(Clinic, Type, _, Start, _), 
            Time < Start. 
        
        sensory_penalty(Patient, Clinic, Time, 2) :- 
            patient(Patient, _, _, _), 
            clinic(Clinic, _), 
            availability(Clinic,_, VisitType, Time), 
            needs(Patient, VisitType, _), 
            sensory_preference(Patient, Type), 
            environmental_condition(Clinic, Type, _, _, End), 
            Time > End. 
        
        sensory_penalty(Patient, Clinic, Time, 0) :- 
            patient(Patient,_,_, _), 
            clinic(Clinic,_), 
            availability(Clinic,_, VisitType, Time), 
            needs(Patient, VisitType, _), 
            not sensory_preference(Patient, _). 
            
        clinic_preference_effect(Patient, Clinic, 1) :- patient(Patient,_,_, _), clinic(Clinic,_), preference(Patient, Clinic). 
        clinic_preference_effect(Patient, Clinic, 0) :- patient(Patient,_,_,_), clinic(Clinic,_), not preference(Patient, Clinic). 
        
        doctor_preference_effect(Patient, Doctor, 1) :- patient(Patient,_,_,_), doctor(Doctor, _, _, _, _, Type), doctor_experience(Doctor, Specialization, YearsOfExperience), doctor_preference(Patient, Type, Specialization, RequiredYears), YearsOfExperience>=RequiredYears. 
        doctor_preference_effect(Patient, Doctor, 0) :- patient(Patient,_,_,_), doctor(Doctor, _, _, _, _, Type), doctor_experience(Doctor, Specialization, _), not doctor_preference(Patient, Type, Specialization, _). 
        doctor_preference_effect(Patient, Doctor, 0) :- patient(Patient,_,_,_), doctor(Doctor, _, _, _, _, Type), doctor_experience(Doctor, Specialization, YearsOfExperience),  doctor_preference(Patient, Type, Specialization, RequiredYears), YearsOfExperience<RequiredYears. 
        
        appointment_preference_effect(Patient, Time, Clinic, 1) :- patient(Patient,_,_,_), clinic(Clinic,_), availability(Clinic, _, _, Time), appointment_preference(Patient, _, Start, End), X = ((((Time\86400)/3600)*100)+(((Time\3600)/60)/3)*5), X<=End, X>=Start.
        appointment_preference_effect(Patient, Time, Clinic, 0) :- patient(Patient,_,_,_), clinic(Clinic,_), availability(Clinic, _, _, Time), appointment_preference(Patient, _, Start, End), X = ((((Time\86400)/3600)*100)+(((Time\3600)/60)/3)*5), X>End.
        appointment_preference_effect(Patient, Time, Clinic, 0) :- patient(Patient,_,_,_), clinic(Clinic,_), availability(Clinic, _, _, Time), appointment_preference(Patient, _, Start, End), X = ((((Time\86400)/3600)*100)+(((Time\3600)/60)/3)*5), X<Start.
        
        Sessions { appointment(Patient, Clinic, Doctor, Visit, Time) : availability(Clinic, Doctor, Visit, Time) } Sessions :-  
            needs(Patient, Visit, _), 
            requested_sessions(Visit, Sessions). 
        
        :- appointment(P1, Clinic, Doctor, Visit, Time), appointment(P2, Clinic, Doctor, Visit, Time), P1 != P2. 
        
        :- needs(P1, Visit, Urg1), needs(P2, Visit, Urg2), Urg1 > Urg2, 
           appointment(P1, Clinic, Doctor, Visit, Time1), appointment(P2, Clinic, Doctor, Visit, Time2), Time1 > Time2. 
        
        :- disabled(Patient), appointment(Patient, Clinic,_, _, _), not accessibile(Clinic). 
        
        chronic_cost(Clinic, TotalCost) :- 
            clinic(Clinic, _), 
            TotalCost = #sum { Cost : appointment(Patient, Clinic, _, Visit, _),  
                                 visit_type(Visit, _, _, 1,_,_), 
                                 chronic_visit_cost(Visit, Cost) }. 
        
        :- chronic_cost(Clinic, TotalCost), budget(Clinic, Budget), TotalCost > Budget. 
        
        :- appointment(Patient, _, _,VisitType, Time1), 
           appointment(Patient, _, _, VisitType, Time2), 
           requested_sessions(VisitType, NumberOfSessions), 
           session_interval(VisitType, Min, Max), 
           NumberOfSessions > 1, 
           Time1 < Time2, 
           ((Time2 - Time1)/86400 ) < Min. 
        
        :- appointment(Patient, _, _, VisitType, Time1), 
           appointment(Patient, _, _, VisitType, Time2), 
           requested_sessions(VisitType, NumberOfSessions), 
           session_interval(VisitType, Min, Max), 
           NumberOfSessions > 1, 
           Time1 < Time2, 
           ((Time2 - Time1)/86400 ) > Max. 
         
        :- patient_interval(Patient, Visit, MinP, MaxP), 
           session_interval(Visit, MinS, MaxS), 
           MinP < MinS.
          
        :- patient_interval(Patient, Visit, MinP, MaxP), 
           session_interval(Visit, MinS, MaxS), 
           MaxP > MaxS. 
        
        :- appointment(Patient, Clinic, Doctor, Visit, Time1), 
           appointment(Patient, Clinic, Doctor, Visit, Time2), 
           requested_sessions(VisitType, NumberOfSessions), 
           session_interval(VisitType, Min, Max), 
           NumberOfSessions > 1, 
           Time1 < Time2, 
           patient_interval(Patient, Visit, MinP, MaxP), 
           ((Time2 - Time1) / 86400) < MinP. 
        
            
        % Vincolo: se una visit richiede più sedute, queste devono rispettare l'intervallo scelto dal cliente - max. 
        :- appointment(Patient, Clinic,Doctor, Visit, Time1), 
           appointment(Patient, Clinic,Doctor, Visit, Time2), 
           requested_sessions(VisitType, NumberOfSessions), 
           session_interval(VisitType, Min, Max), 
           NumberOfSessions > 1, 
           Time1 < Time2, 
           patient_interval(Patient, Visit, MinP, MaxP), 
           ((Time2 - Time1) / 86400) > MaxP.    
        
        % Vincolo: per un appointment a domicilio il doctor non puo vivere in un comune diverso dal patient
        :- appointment(Patient, Clinic, Doctor, Visit, Time),
           clinic(Clinic, "Home Care"),
           patient(Patient, _, _, ResidencePatient),
           doctor(Doctor, _, _, _, ResidenceDoctor, _),
           ResidencePatient != ResidenceDoctor.
           
        :- appointment(Patient, Clinic, Doctor, Visit, Time),
           visit_type(Visit, _, _, _, 1, _),
           clinic(Clinic, "Home Care").
           
        :- appointment(Patient, Clinic, Doctor, Visit, Time),
           visit_type(Visit, _, _, _, 1, _),
           clinic(Clinic, "Telemedicine").
           
        :- appointment(Patient, Clinic, Doctor, Visit, Time),
           visit_type(Visit, _, _, _, _, 1),
           clinic(Clinic, "Telemedicine").
        
        % Funzione di minimizzazione 
        #minimize { 
            (Distance * 10000) + WaitTime + (Penalty * 1000) - (ClinicPreference * 1000) + (DoctorPreference * 1000) + (AppointmentPreference * 1000) :
            distance(Patient, Clinic, Distance), 
            appointment(Patient, Clinic, Doctor, _, Time), 
            current_time(CurrentTime), 
            WaitTime = Time - CurrentTime, 
            sensory_penalty(Patient, Clinic, Time, Penalty), 
            clinic_preference_effect(Patient, Clinic, ClinicPreference), 
            doctor_preference_effect(Patient, Doctor, DoctorPreference),
            appointment_preference_effect(Patient, Clinic, Time, AppointmentPreference)
        }. 
        #show appointment/5.
    """
    # print("program", program)
    print("started")
    start = time.time()
    ctl.add("base", [], program)
    ctl.ground([("base", [])])
    # Solve and print answer sets
    sol = ""
    with ctl.solve(yield_=True) as handle:
        for model in handle:
            sol = str(model)

    end = time.time()
    print(f"Tempo di esecuzione: {end - start:.4f} secondi")
    if sol != "":
        #print("sol:\n\t", sol)
        return {"solution: " : sol.split(" ")}, 200
    else:
        return {"message": "No solution found"}, 200
        
def random_timestamp(timestamps):


    # Calcola i limiti di tempo
    now = datetime.now()

    start = now + timedelta(days=30)  # 1 mese da ora
    end = now + timedelta(days=60)  # 2 mesi da ora

    # Converti in timestamp UNIX (secondi da epoch)
    start_timestamp = int(start.timestamp())
    end_timestamp = int(end.timestamp())
    # Genera un timestamp casuale nell'intervallo
    while True:
        # Genera un timestamp casuale
        random_timestamp = str(random.randint(start_timestamp, end_timestamp))
        if random_timestamp not in timestamps:
            break
    return random_timestamp

while True:
    num_of_patients = int(input("Inserisci in numero dei pazienti: "))
    ###### num of visits = 1
    # num_of_clinics = int(num_of_patients/100) + 1
    # num_of_doctors = int(num_of_patients/10) + 1
    # num_of_visit = 1
    # num_of_appointments = num_of_patients*num_of_clinics

    ##### num of visits = 2
    num_of_clinics = int(num_of_patients/10) + 1
    num_of_doctors = int(num_of_patients/10) + 1
    num_of_visit = num_of_patients
    num_of_appointments = (num_of_patients*num_of_clinics)

    patients = ""
    for p in range(num_of_patients):
        patients += f'\tpatient(p{str(p)}, "name{str(p)}", "surname{str(p)}", "residence{str(int(p/10))}").\n'

    clinics = ""
    for c in range(num_of_clinics):
        clinics += f'\tclinic(c{str(c)}, "name{str(c)}").\n'

    doctors = ""
    for d in range(num_of_doctors):
        doctors += f'\tdoctor(d{str(d)}, "name{str(d)}", "surname{str(d)}", {str(int(d/10))}, "residence{str(int(d/10))}", "specialization{str(int(d/10))}").\n'

    distances = ""
    for p in range(num_of_patients):
        for c in range(num_of_clinics):
            d = str(random.randint(1, 100))
            distances += f'\tdistance(p{str(p)}, c{str(c)}, {d}).\n'

    visit = ""
    for v in range(num_of_visit):
        visit += f'\tvisit_type(v{str(v)}, "type{str(v)}", "name{str(v)}", 0, 0, 0).\n'

    needs = ""
    for p in range(num_of_patients):
        prority = str(random.randint(1, 3))
        v = str(p % num_of_visit)
        needs += f'\tneeds(p{str(p)}, v{v}, {prority}).\n'

    requested_sessions = ""
    for rs in range(num_of_visit):
        requested_sessions += f'\trequested_sessions(v{str(rs)}, 1).\n'

    availability = ""
    timestamps = []
    # num of availabilities = num of patients * num of clinics and doctors are asigned randomly with unixtimestamp > than one month from now
    for p in range(num_of_patients):
        for c in range(num_of_clinics):
            schedule = random_timestamp(timestamps)
            v = str(p % num_of_visit)
            timestamps.append(schedule)
            d = random.randint(0, num_of_doctors-1)
            availability += f'\tavailability(c{str(c)}, d{str(d)}, v{v}, {schedule}).\n'

    current_time = '\tcurrent_time(' + str(int(time.time())) + ').\n'
    
    
    facts = patients + clinics + doctors + distances + visit + needs + availability + current_time + requested_sessions
    solve(facts)