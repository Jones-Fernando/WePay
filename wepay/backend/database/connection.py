import os
import mysql.connector
from mysql.connector import pooling
from contextlib import contextmanager
from database.config import Config

SQL_FILE = os.path.join(os.path.dirname(__file__), 'wepay.sql')


def _ensure_database():
    conn = mysql.connector.connect(
        host=Config.DB_HOST,
        user=Config.DB_USER,
        password=Config.DB_PASSWORD,
        autocommit=True,
    )
    cursor = conn.cursor()
    cursor.execute(
        f"CREATE DATABASE IF NOT EXISTS {Config.DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    )
    cursor.close()
    conn.close()


def _ensure_schema():
    if not os.path.exists(SQL_FILE):
        return

    with open(SQL_FILE, encoding='utf-8-sig') as f:
        sql = f.read()

    conn = mysql.connector.connect(
        host=Config.DB_HOST,
        user=Config.DB_USER,
        password=Config.DB_PASSWORD,
        autocommit=True,
    )
    cursor = conn.cursor()

    for statement in sql.split(';'):
        statement = statement.strip()
        if not statement:
            continue
        cursor.execute(statement)

    cursor.close()
    conn.close()


_ensure_database()
_ensure_schema()


db_pool = mysql.connector.pooling.MySQLConnectionPool(
    pool_name="wepay_pool",
    pool_size=10,
    pool_reset_session=True,
    host=Config.DB_HOST,
    user=Config.DB_USER,
    password=Config.DB_PASSWORD,
    database=Config.DB_NAME
)


@contextmanager
def get_connection_context():
    connection = db_pool.get_connection()
    try:
        yield connection
    finally:
        connection.close()


def get_connection():
    return db_pool.get_connection()


def close_connection(connection):
    connection.close()
  