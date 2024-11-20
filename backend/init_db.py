import os
import psycopg2
from psycopg2.extras import RealDictCursor
import bcrypt

def init_db():
    conn = psycopg2.connect(
        dbname=os.getenv('DATABASE_NAME'),
        user=os.getenv('DATABASE_USER'),
        password=os.getenv('DATABASE_PASSWORD'),
        host=os.getenv('DATABASE_HOST'),
        port=os.getenv('DATABASE_PORT')
    )
    cursor = conn.cursor()

    try:
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id SERIAL PRIMARY KEY,
                username TEXT NOT NULL UNIQUE,
                password BYTEA NOT NULL
            )
        ''')
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS sales (
                id SERIAL PRIMARY KEY,
                username TEXT NOT NULL,
                item TEXT NOT NULL,
                quantity INTEGER NOT NULL,
                price REAL NOT NULL,
                total_price REAL NOT NULL DEFAULT 0.0,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS menu (
                id SERIAL PRIMARY KEY,
                name TEXT NOT NULL UNIQUE,
                price REAL NOT NULL
            )
        ''')

        # Insertar el usuario administrador por defecto
        admin_password = bcrypt.hashpw('0000'.encode('utf-8'), bcrypt.gensalt())
        try:
            cursor.execute('INSERT INTO users (username, password) VALUES (%s, %s)', ('admin', admin_password))
            conn.commit()
            print("Usuario admin creado exitosamente.")
        except psycopg2.IntegrityError:
            conn.rollback()
            print("Usuario admin ya existe.")

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
                cursor.execute('INSERT INTO menu (name, price) VALUES (%s, %s)', plato)
                conn.commit()
            except psycopg2.IntegrityError:
                conn.rollback()
                print(f"Plato {plato[0]} ya existe.")

    except psycopg2.Error as e:
        print(f"Error: {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    init_db()
    print("Base de datos inicializada")