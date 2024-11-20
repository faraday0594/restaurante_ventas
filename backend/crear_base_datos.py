import sqlite3
import bcrypt

def init_db():
    conn = sqlite3.connect('restaurant.db')
    try:
        conn.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT NOT NULL UNIQUE,
                password TEXT NOT NULL
            )
        ''')
        conn.execute('''
            CREATE TABLE IF NOT EXISTS sales (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT NOT NULL,
                item TEXT NOT NULL,
                quantity INTEGER NOT NULL,
                price REAL NOT NULL,
                total_price REAL NOT NULL,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        conn.execute('''
            CREATE TABLE IF NOT EXISTS menu (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL UNIQUE,
                price REAL NOT NULL
            )
        ''')
        
        # Insertar el usuario administrador por defecto
        admin_password = bcrypt.hashpw('0000'.encode('utf-8'), bcrypt.gensalt())
        try:
            conn.execute('INSERT INTO users (username, password) VALUES (?, ?)', ('admin', admin_password))
            conn.commit()
        except sqlite3.IntegrityError:
            pass  # El usuario ya existe, no hace nada

        # Insertar los platos en la tabla menu
        platos = [
            ('Almuerzo Carne Asada', 12000),
            ('Almuerzo Lomo de Cerdo', 12000),
            ('Almuerzo Hígado', 12000),
            ('Almuerzo Corazón', 12000),
            ('Almuerzo Riñón', 12000),
            ('Almuerzo Chunchulla', 12000),
            ('Almuerzo Pata Sudada', 12000),
            ('Almuerzo Albóndigas', 12000)
        ]
        for plato in platos:
            try:
                conn.execute('INSERT INTO menu (name, price) VALUES (?, ?)', plato)
                conn.commit()
            except sqlite3.IntegrityError:
                pass  # El plato ya existe, no hace nada
    except sqlite3.Error as e:
        print(f"Error: {e}")
    finally:
        conn.close()

if __name__ == '__main__':
    init_db()
    print("Base de datos inicializada")