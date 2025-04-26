import mysql.connector

# Replace these with your own DB details
config = {
    'user': 'admin',
    'password': 'password',
    'host': 'localhost',  # or IP of your MySQL server
    'database': 'main',
    'port': 3306
}

def get_pazienti_cliniche_visita(paziente_id,visita_id):
    conn = mysql.connector.connect(**config)
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM main.view_pazienti_cliniche_visita WHERE paziente_id = %s and visita_id = %s", (paziente_id,visita_id))
        clinics = cursor.fetchall()
        return clinics

    except mysql.connector.Error as err:
        pass
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()
