import sqlite3

def clear_sales_data():
    conn = sqlite3.connect('restaurant.db')
    try:
        # Eliminar todos los registros de la tabla sales
        conn.execute('DELETE FROM sales')
        conn.commit()
        print("Todos los registros de ventas han sido eliminados.")
    except sqlite3.Error as e:
        print(f"Error al eliminar los registros de ventas: {e}")
    finally:
        conn.close()

if __name__ == '__main__':
    clear_sales_data()