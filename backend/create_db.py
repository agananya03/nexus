import psycopg2
from app.core.config import DATABASE_URL
from urllib.parse import urlparse

u = urlparse(DATABASE_URL)
conn = psycopg2.connect(
    host=u.hostname,
    port=u.port or 5432,
    user=u.username,
    password=u.password,
    dbname='postgres'
)
conn.autocommit = True
cur = conn.cursor()
cur.execute("SELECT 1 FROM pg_database WHERE datname='nexus_db'")
exists = cur.fetchone()
if not exists:
    cur.execute("CREATE DATABASE nexus_db")
    print("Database 'nexus_db' created!")
else:
    print("Database 'nexus_db' already exists.")
conn.close()
