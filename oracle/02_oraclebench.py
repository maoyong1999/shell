# 首先需要确保已经安装了cx_Oracle库，如果没有，你可以使用以下命令来安装：
# python3 -m pip install cx_Oracle
import cx_Oracle
import time

# Oracle数据库的连接信息
dsn = cx_Oracle.makedsn("192.168.100.10", 1521, service_name="xe")
connection = cx_Oracle.connect(user="system", password="oracle", dsn=dsn)

# 要执行的SQL语句
create_table_query = """
CREATE TABLE test_table (
    id NUMBER,
    data1 VARCHAR2(100),
    data2 VARCHAR2(100),
    data3 VARCHAR2(100),
    data4 VARCHAR2(100),
    data5 VARCHAR2(100),
    data6 VARCHAR2(100),
    data7 VARCHAR2(100),
    data8 VARCHAR2(100),
    data9 VARCHAR2(100),
    data10 VARCHAR2(100)
)
"""
insert_query = """
INSERT INTO test_table (id, data1, data2, data3, data4, data5, data6, data7, data8, data9, data10)
VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11)
"""
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
        cursor.execute(insert_query, (i, f"data{i}", f"data{i}", f"data{i}", f"data{i}", f"data{i}", f"data{i}", f"data{i}", f"data{i}", f"data{i}", f"data{i}"))
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