import cx_Oracle
import time

# Oracle数据库的连接信息
dsn = cx_Oracle.makedsn("192.168.100.10", 1521, service_name="xe")
connection = cx_Oracle.connect(user="system", password="oracle", dsn=dsn)

# 要执行的SQL语句
create_table_query = "CREATE TABLE test_table (id NUMBER, data VARCHAR2(100))"
insert_query = "INSERT INTO test_table (id, data) VALUES (:1, :2)"
select_query = "SELECT * FROM test_table"
drop_table_query = "DROP TABLE test_table"

# 执行创建表的操作，并测量执行时间
start_time = time.time()
with connection.cursor() as cursor:
    cursor.execute(create_table_query)
print(f"Table created in {time.time() - start_time} seconds")

# 执行插入数据的操作，并测量执行时间
start_time = time.time()
with connection.cursor() as cursor:
    for i in range(1000):
        cursor.execute(insert_query, (i, f"data{i}"))
connection.commit()
print(f"Inserted 1000 rows in {time.time() - start_time} seconds")

# 执行查询操作，并测量执行时间
start_time = time.time()
with connection.cursor() as cursor:
    cursor.execute(select_query)
    rows = cursor.fetchall()
print(f"Selected {len(rows)} rows in {time.time() - start_time} seconds")

# 执行删除表的操作，并测量执行时间
start_time = time.time()
with connection.cursor() as cursor:
    cursor.execute(drop_table_query)
print(f"Table dropped in {time.time() - start_time} seconds")