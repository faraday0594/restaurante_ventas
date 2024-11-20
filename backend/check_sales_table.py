import os
import psycopg2
from psycopg2.extras import RealDictCursor

def check_sales_table():
    conn = psycopg2.connect(
        dbname=os.getenv('DATABASE_NAME'),
        user=os.getenv('DATABASE_USER'),
        password=os.getenv('DATABASE_PASSWORD'),
        host=os.getenv('DATABASE_HOST'),
        port=os.getenv('DATABASE_PORT')
    )
    cursor = conn.cursor()

    try:
        cursor.execute('SELECT column_name FROM information_schema.columns WHERE table_name = %s', ('sales',))
        columns = cursor.fetchall()
        for column in columns:
            print(column)
    except psycopg2.Error as e:
        print(f"Error: {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    check_sales_table()