import os
import psycopg2
from psycopg2.extras import RealDictCursor
import bcrypt

def create_user(username, password):
    conn = psycopg2.connect(
        dbname=os.getenv('DATABASE_NAME'),
        user=os.getenv('DATABASE_USER'),
        password=os.getenv('DATABASE_PASSWORD'),
        host=os.getenv('DATABASE_HOST'),
        port=os.getenv('DATABASE_PORT')
    )
    cursor = conn.cursor()

    # Encriptar la contraseña
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

    try:
        cursor.execute('INSERT INTO users (username, password) VALUES (%s, %s)', (username, hashed_password))
        conn.commit()
        print(f"Usuario {username} creado exitosamente.")
    except psycopg2.IntegrityError:
        conn.rollback()
        print(f"Usuario {username} ya existe.")
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    # Solicitar el nombre de usuario y la contraseña
    username = input("Ingrese el nombre de usuario: ")
    password = input("Ingrese la contraseña: ")

    # Crear el usuario
    create_user(username, password)