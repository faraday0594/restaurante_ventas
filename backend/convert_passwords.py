import sqlite3
import bcrypt

def convert_passwords_to_bytes():
    # Conectar a la base de datos
    conn = sqlite3.connect('restaurant.db')
    cursor = conn.cursor()

    # Obtener todos los usuarios
    cursor.execute('SELECT id, username, password FROM users')
    users = cursor.fetchall()

    for user in users:
        user_id = user[0]
        username = user[1]
        password = user[2]  # La contraseña ya está en formato de bytes

        # Re-encriptar la contraseña si es necesario
        if isinstance(password, str):
            password = password.encode('utf-8')
            hashed_password = bcrypt.hashpw(password, bcrypt.gensalt())
            cursor.execute('UPDATE users SET password = ? WHERE id = ?', (hashed_password, user_id))

    conn.commit()
    conn.close()

    print("Contraseñas convertidas exitosamente.")

if __name__ == '__main__':
    convert_passwords_to_bytes()