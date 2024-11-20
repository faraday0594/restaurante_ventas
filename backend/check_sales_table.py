import sqlite3

def check_sales_table():
    conn = sqlite3.connect('restaurant.db')
    cursor = conn.cursor()
    cursor.execute('PRAGMA table_info(sales)')
    columns = cursor.fetchall()
    conn.close()
    for column in columns:
        print(column)

if __name__ == '__main__':
    check_sales_table()