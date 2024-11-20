import sqlite3

def add_total_price_column_to_sales():
    conn = sqlite3.connect('restaurant.db')
    try:
        conn.execute('ALTER TABLE sales ADD COLUMN total_price REAL NOT NULL DEFAULT 0.0')
        conn.commit()
        print("Columna total_price añadida a la tabla sales")
    except sqlite3.OperationalError as e:
        print(f"Error: {e}")
    finally:
        conn.close()

if __name__ == '__main__':
    add_total_price_column_to_sales()