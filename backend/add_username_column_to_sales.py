import sqlite3

def add_username_column_to_sales():
    conn = sqlite3.connect('restaurant.db')
    try:
        conn.execute('ALTER TABLE sales ADD COLUMN username TEXT NOT NULL DEFAULT ""')
        conn.commit()
        print("Columna username añadida a la tabla sales")
    except sqlite3.OperationalError as e:
        print(f"Error: {e}")
    finally:
        conn.close()

if __name__ == '__main__':
    add_username_column_to_sales()