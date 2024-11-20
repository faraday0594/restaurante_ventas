import os
import psycopg2
from psycopg2.extras import RealDictCursor

def add_username_column_to_sales():
    conn = psycopg2.connect(
        dbname=os.getenv('DATABASE_NAME'),
        user=os.getenv('DATABASE_USER'),
        password=os.getenv('DATABASE_PASSWORD'),
        host=os.getenv('DATABASE_HOST'),
        port=os.getenv('DATABASE_PORT')
    )
    cursor = conn.cursor()

    try:
        cursor.execute('ALTER TABLE sales ADD COLUMN IF NOT EXISTS username TEXT NOT NULL DEFAULT %s', ('',))
        conn.commit()
        print("Columna username añadida a la tabla sales")
    except psycopg2.OperationalError as e:
        print(f"Error: {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    add_username_column_to_sales()