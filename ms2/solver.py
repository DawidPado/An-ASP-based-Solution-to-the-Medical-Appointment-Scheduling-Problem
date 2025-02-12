import clingo

def solve(facts):
    ctl = clingo.Control()
    if facts == []:
        return {"message": "No fact provided"}, 400

    program = ""
    for fact in facts:
        program += f"{fact}\n"
    program += """
   
    penalita_sensoriale(Paziente, Clinica, Orario, Livello) :- 
        paziente(Paziente,_,_), 
        clinica(Clinica,_), 
        disponibilita(Clinica, Tipo_di_visita, Orario), 
        necessita(Paziente, Tipo_di_visita, _), 
        preferenza_sensoriale(Paziente, Tipo), 
        condizione_ambientale(Clinica, Tipo, Livello, Inizio, Fine), 
        Orario >= Inizio, Orario <= Fine. 
    
    penalita_sensoriale(Paziente, Clinica, Orario, 2) :- 
        paziente(Paziente, _, _), 
        clinica(Clinica, _), 
        disponibilita(Clinica, Tipo_di_visita, Orario), 
        necessita(Paziente, Tipo_di_visita, _), 
        preferenza_sensoriale(Paziente, Tipo), 
        not condizione_ambientale(Clinica, Tipo, _, _, _). 
    
    penalita_sensoriale(Paziente, Clinica, Orario, 2) :- 
        paziente(Paziente, _, _), 
        clinica(Clinica, _), 
        disponibilita(Clinica, Tipo_di_visita, Orario), 
        necessita(Paziente, Tipo_di_visita, _), 
        preferenza_sensoriale(Paziente, Tipo), 
        condizione_ambientale(Clinica, Tipo, _, Inizio, _), 
        Orario < Inizio. 
    
    penalita_sensoriale(Paziente, Clinica, Orario, 2) :- 
        paziente(Paziente, _, _), 
        clinica(Clinica, _), 
        disponibilita(Clinica, Tipo_di_visita, Orario), 
        necessita(Paziente, Tipo_di_visita, _), 
        preferenza_sensoriale(Paziente, Tipo), 
        condizione_ambientale(Clinica, Tipo, _, _, Fine), 
        Orario > Fine. 
    
    penalita_sensoriale(Paziente, Clinica, Orario, 0) :- 
        paziente(Paziente,_,_), 
        clinica(Clinica,_), 
        disponibilita(Clinica, Tipo_di_visita, Orario), 
        necessita(Paziente, Tipo_di_visita, _), 
        not preferenza_sensoriale(Paziente, _). 
    
    
    preferenza_effetto(Paziente, Clinica, 1) :- paziente(Paziente,_,_), clinica(Clinica,_), preferenza(Paziente, Clinica). 
    preferenza_effetto(Paziente, Clinica, 0) :- paziente(Paziente,_,_), clinica(Clinica,_), not preferenza(Paziente, Clinica). 
    
    Sedute { appuntamento(Paziente, Clinica, Visita, Orario) : disponibilita(Clinica, Visita, Orario) } Sedute :-  
        necessita(Paziente, Visita, _), 
        sedute_richieste(Visita, Sedute). 
    
    :- appuntamento(P1, Clinica, Visita, Orario), appuntamento(P2, Clinica, Visita, Orario), P1 != P2. 
    
    :- necessita(P1, Visita, Urg1), necessita(P2, Visita, Urg2), Urg1 > Urg2, 
       appuntamento(P1, Clinica, Visita, Orario1), appuntamento(P2, Clinica, Visita, Orario2), Orario1 > Orario2. 
    
    :- disabile(Paziente), appuntamento(Paziente, Clinica, _, _), not accessibile(Clinica). 
    
    costo_cronici(Clinica, CostoTotale) :- 
        clinica(Clinica, _), 
        CostoTotale = #sum { Costo : appuntamento(Paziente, Clinica, Visita, _),  
                             tipo_di_visita(Visita, _, _, 1), 
                             costo_visita(Visita, Costo) }. 
    
    :- costo_cronici(Clinica, CostoTotale), budget(Clinica, Budget), CostoTotale > Budget. 
    
    :- appuntamento(Paziente, _, Tipo_di_visita, Orario1), 
       appuntamento(Paziente, _, Tipo_di_visita, Orario2), 
       sedute_richieste(Tipo_di_visita, NumeroSedute), 
       intervallo_sedute(Tipo_di_visita, Min, Max), 
       NumeroSedute > 1, 
       Orario1 < Orario2, 
       ((Orario2 - Orario1)/86400 ) < Min. 
    
    :- appuntamento(Paziente, _, Tipo_di_visita, Orario1), 
       appuntamento(Paziente, _, Tipo_di_visita, Orario2), 
       sedute_richieste(Tipo_di_visita, NumeroSedute), 
       intervallo_sedute(Tipo_di_visita, Min, Max), 
       NumeroSedute > 1, 
       Orario1 < Orario2, 
       ((Orario2 - Orario1)/86400 ) > Max. 
    
    :- intervallo_paziente(Paziente, Visita, MinP, MaxP), 
       intervallo_sedute(Visita, MinS, MaxS), 
       MinP < MinS. 
    
    :- intervallo_paziente(Paziente, Visita, MinP, MaxP), 
       intervallo_sedute(Visita, MinS, MaxS), 
       MaxP > MaxS. 
    
    :- appuntamento(Paziente, Clinica, Visita, Orario1), 
       appuntamento(Paziente, Clinica, Visita, Orario2), 
       sedute_richieste(Tipo_di_visita, NumeroSedute), 
       intervallo_sedute(Tipo_di_visita, Min, Max), 
       NumeroSedute > 1, 
       Orario1 < Orario2, 
       intervallo_paziente(Paziente, Visita, MinP, MaxP), 
       ((Orario2 - Orario1) / 86400) < MinP. 
    
    :- appuntamento(Paziente, Clinica, Visita, Orario1), 
       appuntamento(Paziente, Clinica, Visita, Orario2), 
       sedute_richieste(Tipo_di_visita, NumeroSedute), 
       intervallo_sedute(Tipo_di_visita, Min, Max), 
       NumeroSedute > 1, 
       Orario1 < Orario2, 
       intervallo_paziente(Paziente, Visita, MinP, MaxP), 
       ((Orario2 - Orario1) / 86400) > MaxP.    
    
    #minimize { 
        (Distanza * 10000) + Attesa + (Penalita * 1000) - (Preferenza * 10000) : 
        distanza(Paziente, Clinica, Distanza), 
        appuntamento(Paziente, Clinica, _, Orario), 
        orario_corrente(OrarioCorrente), 
        Attesa = Orario - OrarioCorrente, 
        penalita_sensoriale(Paziente, Clinica, Orario, Penalita), 
        preferenza_effetto(Paziente, Clinica, Preferenza) 
    }. 
    #show appuntamento/4. 
 """
    ctl.add("base", [], program)
    ctl.ground([("base", [])])
    # Solve and print answer sets
    sol = ""
    with ctl.solve(yield_=True) as handle:
        for model in handle:
            sol = str(model)
    if sol != "":

        return {"soluzione: " : sol.split(" ")}, 200
    else:
        return {"message": "No solution found"}, 200