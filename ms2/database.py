import mysql.connector

# Replace these with your own DB details
config = {
    'user': 'admin',
    'password': 'password',
    'host': 'localhost',  # or IP of your MySQL server
    'database': 'main',
    'port': 3306
}

try:
    connection = mysql.connector.connect(**config)
    print("Connected to MySQL!")

    # Create a cursor and execute a query
    cursor = connection.cursor()
    query = "SELECT * FROM view_pazienti_cliniche"

    # Execute the query
    cursor.execute(query)

    # Fetch all the results
    results = cursor.fetchall()

    # Process the results (printing here for simplicity)
    for row in results:
        paziente_id, paziente_nome, paziente_cognome, clinica_id, clinica_nome, distanza_km = row
        print(f"Paziente: {paziente_nome} {paziente_cognome} (ID: {paziente_id}), "
              f"Clinica: {clinica_nome} (ID: {clinica_id}), Distanza: {distanza_km} km")

except mysql.connector.Error as err:
    print("Error:", err)

finally:
    if connection.is_connected():
        cursor.close()
        connection.close()
        print("Connection closed.")
