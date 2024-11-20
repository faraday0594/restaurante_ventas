import sqlite3
import bcrypt

def create_user(username, password):
    # Conectar a la base de datos
    conn = sqlite3.connect('restaurant.db')
    cursor = conn.cursor()

    # Encriptar la contraseña
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

    # Insertar el nuevo usuario en la base de datos
    cursor.execute('INSERT INTO users (username, password) VALUES (?, ?)', (username, hashed_password))
    conn.commit()

    # Cerrar la conexión
    conn.close()

    print(f"Usuario {username} creado exitosamente.")

if __name__ == '__main__':
    # Solicitar el nombre de usuario y la contraseña
    username = input("Ingrese el nombre de usuario: ")
    password = input("Ingrese la contraseña: ")

    # Crear el usuario
    create_user(username, password)