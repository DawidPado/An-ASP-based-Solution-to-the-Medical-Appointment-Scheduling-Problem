import mysql.connector

# Replace these with your own DB details
config = {
    'user': 'admin',
    'password': 'password',
    'host': 'localhost',  # or IP of your MySQL server
    'database': 'main',
    'port': 3306
}

def next_upcoming_appointments(patient_id,view_id):
    conn = mysql.connector.connect(**config)
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM main.next_upcoming_appointments WHERE patient_id = %s and view_id = %s", (patient_id,view_id))
        clinics = cursor.fetchall()
        return clinics

    except mysql.connector.Error as err:
        pass
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()
def insert_appointments(appointments):
    conn = mysql.connector.connect(**config)
    cursor = conn.cursor(dictionary=True)
    try:
        for appointment in appointments:
            cursor.execute("INSERT INTO main.appointments (patient_id, clinic_id, doctor_id, visit_id, time) VALUES (%s, %s, %s, %s, %s)",
                           (appointment["patient_id"], appointment["clinic_id"], appointment["doctor_id"], appointment["visit_id"], appointment["time"]))
            conn.commit()
            cursor.execute("UPDATE main.availabilities SET available = 0 WHERE appointment_id = %s", (appointment["id"],))
            conn.commit()
    except mysql.connector.Error as err:
        pass
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

def remove_appointment(appointment_id):
    conn = mysql.connector.connect(**config)
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("DELETE FROM main.appointments WHERE id = %s", (appointment_id,))
        conn.commit()
        cursor.execute("UPDATE main.availabilities SET available = 1 WHERE appointment_id = %s", (appointment_id,))
        conn.commit()
    except mysql.connector.Error as err:
        pass
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()