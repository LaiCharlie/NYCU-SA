# path : /home/judge/webserver/main.py or wherever you want
# command : uvicorn main:app --host 192.168.108.1 --port 8080 --reload

from fastapi import FastAPI, File, UploadFile, HTTPException, Path
from fastapi.responses import FileResponse, JSONResponse
from psycopg2.extras   import RealDictCursor
import os
import socket
import psycopg2

app = FastAPI()

# Test command:
# curl -X POST "https://file.108.cs.nycu/upload" -F "file=@/home/judge/webserver/main.py"
# curl -X GET  "https://file.108.cs.nycu/file/main.py" -O

DB_CONFIG = {
    "host":     "192.168.108.1",
    "database": "sa-hw4",
    "user":     "root",
    "password": "sahw4-108"
}

def get_db_connection():
    return psycopg2.connect(**DB_CONFIG, cursor_factory=RealDictCursor)

@app.get("/ip")
def get_ip():
    try:
        hostname = socket.gethostname()
        return {"ip": "192.168.108.1", "hostname": hostname}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

UPLOAD_DIR = "./upload"

@app.get("/file/{filename}")
def read_file(filename: str = Path(..., description="The name of the file to read.")):
    file_path = os.path.join(UPLOAD_DIR, filename)
    if os.path.isfile(file_path):
        return FileResponse(file_path)
    raise HTTPException(status_code=404, detail="File not found")

@app.post("/upload")
def upload_file(file: UploadFile = File(...)):
    try:
        file_path = os.path.join(UPLOAD_DIR, file.filename)
        with open(file_path, "wb") as f:
            f.write(file.file.read())
        return {"filename": file.filename, "success": True}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/db/{username}")
def get_user(username: str):
    try:
        conn = get_db_connection()
        cur  = conn.cursor()
        query = 'SELECT * FROM "user" WHERE name = %s;'
        cur.execute(query, (username,))
        user = cur.fetchone()
        cur.close()
        conn.close()

        if user:
            return user
        raise HTTPException(status_code=404, detail="User not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# curl -sLk -X POST -F \"file=@test.txt\" -H \"Host: file.108.cs.nycu\" \"$scheme://192.168.108.1/upload\"