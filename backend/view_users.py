import sqlite3

def view_users():
    # Conectar a la base de datos
    conn = sqlite3.connect('restaurant.db')
    cursor = conn.cursor()

    # Obtener todos los usuarios
    cursor.execute('SELECT * FROM users')
    users = cursor.fetchall()

    # Imprimir los usuarios
    for user in users:
        print(user)

    # Cerrar la conexión
    conn.close()

if __name__ == '__main__':
    view_users()