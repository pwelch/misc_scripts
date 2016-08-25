from flask import Flask
import psycopg2

###
# Simple Python/Flask app to test Postgres Connection
###
app = Flask(__name__)

def db_connection():
  conn_string = "host='localhost' dbname='postgres' user='postgres' password=''"
  try:
    # get a connection, if a connect cannot be made an exception will be raised here
    conn = psycopg2.connect(conn_string)
  except:
    return "Database Connection Failed!"

  # conn.cursor will return a cursor object, you can use this cursor to perform queries
  cursor = conn.cursor()

  # execute our Query
  cursor.execute("SELECT 1")
  return "Database Connection Successful!"

@app.route('/')
def hello():
    result = db_connection()
    return result

if __name__ == '__main__':
    app.run(host='0.0.0.0')

# pip install -r /path/to/requirements.txt
# Flask==0.11
# psycopg2==2.6.1

# python app.py
