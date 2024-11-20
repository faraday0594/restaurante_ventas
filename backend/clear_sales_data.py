import os
import psycopg2
from psycopg2.extras import RealDictCursor

def clear_sales_data():
    conn = psycopg2.connect(
        dbname=os.getenv('DATABASE_NAME'),
        user=os.getenv('DATABASE_USER'),
        password=os.getenv('DATABASE_PASSWORD'),
        host=os.getenv('DATABASE_HOST'),
        port=os.getenv('DATABASE_PORT')
    )
    cursor = conn.cursor()

    try:
        # Eliminar todos los registros de la tabla sales
        cursor.execute('DELETE FROM sales')
        conn.commit()
        print("Todos los registros de ventas han sido eliminados.")
    except psycopg2.Error as e:
        print(f"Error al eliminar los registros de ventas: {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    clear_sales_data()