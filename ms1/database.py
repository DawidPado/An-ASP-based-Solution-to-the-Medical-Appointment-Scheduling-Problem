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
    {
        "name": "Admin",
        "surname": "Admin",
        "residence": "L'Aquila",
        "birth": "1980-03-12",
        "email": "admin@email.com",
        "password": "password123",
        "condition": "Hypertension",
        "difficulties": "Difficulty walking",
        "goals": "Prevention",
        "technologies": "Telemedicine",
        "environment": "Lives with wife",
        "latitude": 42.3492,
        "longitude": 13.3984
    }

    keys = ["name", "surname", "residence", "birth", "email","password", "condition", "difficulties", "goals", "technologies", "environment", "latitude", "longitude"]
    for key in keys:
        if key not in data.keys():
            raise ValueError(f"Missing required parameter: {key}")
    try:
        conn = mysql.connector.connect(**config)
        cursor = conn.cursor(dictionary=True)
        result = cursor.callproc('register_patient', [
            data["name"],
            data["surname"],
            data["residence"],
            data["birth"],
            data["email"],
            data["password"],
            data["condition"],
            data["difficulties"],
            data["goals"],
            data["technologies"],
            data["environment"],
            data["latitudine"],
            data["longitudine"],
            0
        ])
        conn.commit()
        cursor.close()
        conn.close()
        output = result['register_patient_arg14']
        if output == 1:
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
