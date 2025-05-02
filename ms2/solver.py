import clingo

def on_message(msg):
    if msg.type != clingo.MessageType.Warning and msg.type != clingo.MessageType.Info:
        print(msg)

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
                                 cronic_visit_cost(Visit, Cost) }. 
        
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
    print("program", program)
    ctl.add("base", [], program)
    ctl.ground([("base", [])])
    # Solve and print answer sets
    sol = ""
    with ctl.solve(yield_=True) as handle:
        for model in handle:
            sol = str(model)
    if sol != "":
        print("sol:\n\t", sol)
        return {"solution: " : sol.split(" ")}, 200
    else:
        return {"message": "No solution found"}, 200