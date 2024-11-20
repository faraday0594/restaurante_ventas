import sqlite3
import bcrypt

def init_db():
    # Conectar a la base de datos
    conn = sqlite3.connect('restaurant.db')
    cursor = conn.cursor()

    # Crear la tabla users
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
    )
    ''')

    # Crear un usuario admin
    admin_username = 'admin'
    admin_password = '0000'
    hashed_password = bcrypt.hashpw(admin_password.encode('utf-8'), bcrypt.gensalt())

    try:
        cursor.execute('INSERT INTO users (username, password) VALUES (?, ?)', (admin_username, hashed_password))
        conn.commit()
        print(f"Usuario {admin_username} creado exitosamente.")
    except sqlite3.IntegrityError:
        print(f"Usuario {admin_username} ya existe.")

    # Cerrar la conexión
    conn.close()

if __name__ == '__main__':
    init_db()