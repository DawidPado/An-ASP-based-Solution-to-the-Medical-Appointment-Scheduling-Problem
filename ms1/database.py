import mysql.connector

# Replace these with your own DB details
config = {
    'user': 'admin',
    'password': 'password',
    'host': 'localhost',  # or IP of your MySQL server
    'database': 'main',
    'port': 3306
}

def login(email, password):
    conn = mysql.connector.connect(**config)
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT u.* FROM credenziali c inner join pazienti u on c.pazienti_id = u.id WHERE email = %s and password = %s", (email,password))
        user = cursor.fetchone()
        return user

    except mysql.connector.Error as err:
        pass
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

def signin(data):
    response = False
    keys = ["nome", "cognome", "residenza", "nascita","email", "password", "condizione", "difficolta", "obiettivi", "tecnologie", "ambiente", "latitudine", "longitudine"]
    for key in keys:
        if key not in data.keys():
            raise ValueError(f"Missing required parameter: {key}")
    try:
        conn = mysql.connector.connect(**config)
        cursor = conn.cursor(dictionary=True)
        result = cursor.callproc('registrazione_paziente', [
            data["nome"],
            data["cognome"],
            data["residenza"],
            data["nascita"],
            data["email"],
            data["password"],
            data["condizione"],
            data["difficolta"],
            data["obiettivi"],
            data["tecnologie"],
            data["ambiente"],
            data["latitudine"],
            data["longitudine"],
            0
        ])
        conn.commit()
        cursor.close()
        conn.close()

        output = result['registrazione_paziente_arg14']
        print(result)
        print(output)
        if output == 1:
            print("Registrazione avvenuta con successo!")
            return login(data["email"], data["password"])
        else:
            return None


    except mysql.connector.Error as err:
        print(f"Errore MySQL: {err}")
        return None

    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()
