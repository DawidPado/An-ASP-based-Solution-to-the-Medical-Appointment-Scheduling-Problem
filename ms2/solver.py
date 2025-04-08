import clingo

def solve(facts):
    ctl = clingo.Control()
    if facts == []:
        return {"message": "No fact provided"}, 400

    program = ""
    for fact in facts:
        program += f"{fact}\n"
    program += """
        % Penalità per le preferenze sensoriali serve nella minimizzazione 
        %penalità presente 
        penalita_sensoriale(Paziente, Clinica, Orario, Livello) :- 
            paziente(Paziente,_,_,_), 
            clinica(Clinica,_), 
            disponibilita(Clinica,_, Tipo_di_visita, Orario), 
            necessita(Paziente, Tipo_di_visita, _), 
            preferenza_sensoriale(Paziente, Tipo), 
            condizione_ambientale(Clinica, Tipo, Livello, Inizio, Fine), 
            Orario >= Inizio, Orario <= Fine. 
        
        %regole di default 
        penalita_sensoriale(Paziente, Clinica, Orario, 2) :- 
            paziente(Paziente, _, _, _), 
            clinica(Clinica, _), 
            disponibilita(Clinica,_, Tipo_di_visita, Orario), 
            necessita(Paziente, Tipo_di_visita, _), 
            preferenza_sensoriale(Paziente, Tipo), 
            not condizione_ambientale(Clinica, Tipo, _, _, _). 
        
        penalita_sensoriale(Paziente, Clinica, Orario, 2) :- 
            paziente(Paziente, _, _, _), 
            clinica(Clinica, _), 
            disponibilita(Clinica,_, Tipo_di_visita, Orario), 
            necessita(Paziente, Tipo_di_visita, _), 
            preferenza_sensoriale(Paziente, Tipo), 
            condizione_ambientale(Clinica, Tipo, _, Inizio, _), 
            Orario < Inizio. 
        
        penalita_sensoriale(Paziente, Clinica, Orario, 2) :- 
            paziente(Paziente, _, _, _), 
            clinica(Clinica, _), 
            disponibilita(Clinica,_, Tipo_di_visita, Orario), 
            necessita(Paziente, Tipo_di_visita, _), 
            preferenza_sensoriale(Paziente, Tipo), 
            condizione_ambientale(Clinica, Tipo, _, _, Fine), 
            Orario > Fine. 
        
        % Penalità di default se il paziente non ha preferenze espresse 
        penalita_sensoriale(Paziente, Clinica, Orario, 0) :- 
            paziente(Paziente,_,_, _), 
            clinica(Clinica,_), 
            disponibilita(Clinica,_, Tipo_di_visita, Orario), 
            necessita(Paziente, Tipo_di_visita, _), 
            not preferenza_sensoriale(Paziente, _). 
            
        % Effetto della preferenza 
        effetto_preferenza_cliniche(Paziente, Clinica, 1) :- paziente(Paziente,_,_, _), clinica(Clinica,_), preferenza(Paziente, Clinica). 
        effetto_preferenza_cliniche(Paziente, Clinica, 0) :- paziente(Paziente,_,_,_), clinica(Clinica,_), not preferenza(Paziente, Clinica). 
        
        effetto_preferenza_medico(Paziente, Medico, 1) :- paziente(Paziente,_,_,_), medico(Medico, _, _, _, _, Tipo), esperienza_medico(Medico, Specializzazione, AnniEsperienza), preferenza_medico(Paziente, Tipo, Specializzazione, Anni_Richiesti), AnniEsperienza>=Anni_Richiesti. 
        effetto_preferenza_medico(Paziente, Medico, 0) :- paziente(Paziente,_,_,_), medico(Medico, _, _, _, _, Tipo), esperienza_medico(Medico, Specializzazione, _), not preferenza_medico(Paziente, Tipo, Specializzazione, _). 
        effetto_preferenza_medico(Paziente, Medico, 0) :- paziente(Paziente,_,_,_), medico(Medico, _, _, _, _, Tipo), esperienza_medico(Medico, Specializzazione, AnniEsperienza),  preferenza_medico(Paziente, Tipo, Specializzazione, Anni_Richiesti), AnniEsperienza<Anni_Richiesti. 
        
        effetto_preferenza_appuntamento(Paziente, Orario, Clinica, 1) :- paziente(Paziente,_,_,_), clinica(Clinica,_), disponibilita(Clinica, _, _, Orario), preferenza_appuntamento(Paziente, _, Inizio, Fine), X = ((((Orario\86400)/3600)*100)+(((Orario\3600)/60)/3)*5), X<=Fine, X>=Inizio.
        effetto_preferenza_appuntamento(Paziente, Orario, Clinica, 0) :- paziente(Paziente,_,_,_), clinica(Clinica,_), disponibilita(Clinica, _, _, Orario), preferenza_appuntamento(Paziente, _, Inizio, Fine), X = ((((Orario\86400)/3600)*100)+(((Orario\3600)/60)/3)*5), X>Fine.
        effetto_preferenza_appuntamento(Paziente, Orario, Clinica, 0) :- paziente(Paziente,_,_,_), clinica(Clinica,_), disponibilita(Clinica, _, _, Orario), preferenza_appuntamento(Paziente, _, Inizio, Fine), X = ((((Orario\86400)/3600)*100)+(((Orario\3600)/60)/3)*5), X<Inizio.
        
        % Vincolo sull'assegnazione degli appuntamenti (modificato) 
        Sedute { appuntamento(Paziente, Clinica, Medico, Visita, Orario) : disponibilita(Clinica, Medico, Visita, Orario) } Sedute :-  
            necessita(Paziente, Visita, _), 
            sedute_richieste(Visita, Sedute). 
        
        % Vincolo sul appuntamento, uno per persona 
        :- appuntamento(P1, Clinica, Medico, Visita, Orario), appuntamento(P2, Clinica, Medico, Visita, Orario), P1 != P2. 
        
        % Vincolo sulla urgenza, chi ha urgenza piu alta viene prima 
        :- necessita(P1, Visita, Urg1), necessita(P2, Visita, Urg2), Urg1 > Urg2, 
           appuntamento(P1, Clinica, Medico, Visita, Orario1), appuntamento(P2, Clinica, Medico, Visita, Orario2), Orario1 > Orario2. 
        
        % Vincolo sulla accessibilta, un paziente disabile non può essere assegnato a una clinica non accessibile 
        :- disabile(Paziente), appuntamento(Paziente, Clinica,_, _, _), not accessibile(Clinica). 
        
        % Calcolo del costo totale delle visite croniche assegnate per ogni clinica 
        costo_cronici(Clinica, CostoTotale) :- 
            clinica(Clinica, _), 
            CostoTotale = #sum { Costo : appuntamento(Paziente, Clinica, _, Visita, _),  
                                 tipo_di_visita(Visita, _, _, 1,_,_), 
                                 costo_visita(Visita, Costo) }. 
        
        % Vincolo: il costo totale per le visite croniche non deve superare il budget 
        :- costo_cronici(Clinica, CostoTotale), budget(Clinica, Budget), CostoTotale > Budget. 
        
        % Vincolo per rispettare l'intervallo temporale tra sedute dello stesso tipo min, non mi fa fare min e max insieme 
        :- appuntamento(Paziente, _, _,Tipo_di_visita, Orario1), 
           appuntamento(Paziente, _, _, Tipo_di_visita, Orario2), 
           sedute_richieste(Tipo_di_visita, NumeroSedute), 
           intervallo_sedute(Tipo_di_visita, Min, Max), 
           NumeroSedute > 1, 
           Orario1 < Orario2, 
           ((Orario2 - Orario1)/86400 ) < Min. 
        
        % Vincolo per rispettare l'intervallo temporale tra sedute dello stesso tipo max 
        :- appuntamento(Paziente, _, _, Tipo_di_visita, Orario1), 
           appuntamento(Paziente, _, _, Tipo_di_visita, Orario2), 
           sedute_richieste(Tipo_di_visita, NumeroSedute), 
           intervallo_sedute(Tipo_di_visita, Min, Max), 
           NumeroSedute > 1, 
           Orario1 < Orario2, 
           ((Orario2 - Orario1)/86400 ) > Max. 
        
        % Vincolo: il minimo dell'intervallo del paziente deve essere maggiore o uguale al minimo dell'intervallo della visita. 
        :- intervallo_paziente(Paziente, Visita, MinP, MaxP), 
           intervallo_sedute(Visita, MinS, MaxS), 
           MinP < MinS.
          
        
        % Vincolo: il massimo dell'intervallo del paziente deve essere minore o uguale al massimo dell'intervallo della visita. 
        :- intervallo_paziente(Paziente, Visita, MinP, MaxP), 
           intervallo_sedute(Visita, MinS, MaxS), 
           MaxP > MaxS. 
        
        % Vincolo: se una visita richiede più sedute, queste devono rispettare l'intervallo scelto dal cliente - min. 
        :- appuntamento(Paziente, Clinica, Medico, Visita, Orario1), 
           appuntamento(Paziente, Clinica, Medico, Visita, Orario2), 
           sedute_richieste(Tipo_di_visita, NumeroSedute), 
           intervallo_sedute(Tipo_di_visita, Min, Max), 
           NumeroSedute > 1, 
           Orario1 < Orario2, 
           intervallo_paziente(Paziente, Visita, MinP, MaxP), 
           ((Orario2 - Orario1) / 86400) < MinP. 
        
            
        % Vincolo: se una visita richiede più sedute, queste devono rispettare l'intervallo scelto dal cliente - max. 
        :- appuntamento(Paziente, Clinica,Medico, Visita, Orario1), 
           appuntamento(Paziente, Clinica,Medico, Visita, Orario2), 
           sedute_richieste(Tipo_di_visita, NumeroSedute), 
           intervallo_sedute(Tipo_di_visita, Min, Max), 
           NumeroSedute > 1, 
           Orario1 < Orario2, 
           intervallo_paziente(Paziente, Visita, MinP, MaxP), 
           ((Orario2 - Orario1) / 86400) > MaxP.    
        
        % Vincolo: per un appuntamento a domicilio il medico non puo vivere in un comune diverso dal paziente
        :- appuntamento(Paziente, Clinica, Medico, Visita, Orario),
           clinica(Clinica, "Assistenza a Domicilio"),
           paziente(Paziente, _, _, ResidenzaPaziente),
           medico(Medico, _, _, _, ResidenzaMedico, _),
           ResidenzaPaziente != ResidenzaMedico.
           
        :- appuntamento(Paziente, Clinica, Medico, Visita, Orario),
           tipo_di_visita(Visita, _, _, _, 1, _),
           clinica(Clinica, "Assistenza a Domicilio").
           
        :- appuntamento(Paziente, Clinica, Medico, Visita, Orario),
           tipo_di_visita(Visita, _, _, _, 1, _),
           clinica(Clinica, "Televisita").
           
        :- appuntamento(Paziente, Clinica, Medico, Visita, Orario),
           tipo_di_visita(Visita, _, _, _, _, 1),
           clinica(Clinica, "Televisita").
        
        % Funzione di minimizzazione 
        #minimize { 
            (Distanza * 10000) + Attesa + (Penalita * 1000) - (PreferenzaClinica * 1000) + (PreferenzaMedico * 1000) + (PreferenzaAppuntamento * 1000) :
            distanza(Paziente, Clinica, Distanza), 
            appuntamento(Paziente, Clinica, Medico, _, Orario), 
            orario_corrente(OrarioCorrente), 
            Attesa = Orario - OrarioCorrente, 
            penalita_sensoriale(Paziente, Clinica, Orario, Penalita), 
            effetto_preferenza_cliniche(Paziente, Clinica, PreferenzaClinica), 
            effetto_preferenza_medico(Paziente, Medico, PreferenzaMedico),
            effetto_preferenza_appuntamento(Paziente, Clinica, Orario, PreferenzaAppuntamento)
        }. 
        #show appuntamento/5.
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