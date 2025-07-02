# Import required modules
import dotenv
import os
import psycopg2
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from psycopg2 import sql
from pydantic import BaseModel

# Load environment variables
dotenv.load_dotenv()

# Initialize FastAPI
app = FastAPI()

# Add CORS middleware for Flutter Web access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # You can restrict to ["http://localhost:PORT"] if needed
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Define Task model
class Task(BaseModel):
    task: str
    done: bool

# PostgreSQL Connection
try:
    conn = psycopg2.connect(
        user=os.environ["POSTGRES_USER"],
        password=os.environ["POSTGRES_PASSWORD"],
        host=os.environ["POSTGRES_HOST"],
        database=os.environ["POSTGRES_DB"]
    )
    cursor = conn.cursor()
    print("✅ Connected to PostgreSQL")
except psycopg2.Error as err:
    print(f"❌ Database connection error: {err}")
    import sys
    sys.exit(1)

# Middleware for API key authentication
async def authenticate(api_key: str):
    try:
        cursor.execute("SELECT api_key FROM api_keys WHERE api_key = %s", (api_key,))
        if not cursor.fetchone():
            raise HTTPException(status_code=401, detail="Forbidden")
    except psycopg2.Error:
        raise HTTPException(status_code=500, detail="Database auth error")

@app.get("/")
async def welcome(api_key: str):
    await authenticate(api_key)
    return {"message": "Welcome to To-Do List API"}

@app.get("/tasks")
async def get_tasks(api_key: str):
    await authenticate(api_key)
    try:
        cursor.execute("SELECT task_id, task, done FROM tasks ORDER BY task_id")
        return cursor.fetchall()
    except psycopg2.Error:
        raise HTTPException(status_code=500, detail="Error fetching tasks")

@app.post("/tasks")
async def create_task(new_task: Task, api_key: str):
    await authenticate(api_key)
    try:
        cursor.execute("INSERT INTO tasks (task, done) VALUES (%s, %s) RETURNING task_id",
                       (new_task.task, new_task.done))
        task_id = cursor.fetchone()[0]
        conn.commit()
        return {"task_id": task_id, "task": new_task.task, "done": new_task.done}
    except psycopg2.Error:
        conn.rollback()
        raise HTTPException(status_code=500, detail="Error creating task")

@app.put("/tasks/{task_id}")
async def update_task(task_id: int, task: Task, api_key: str):
    await authenticate(api_key)
    try:
        cursor.execute("SELECT task_id FROM tasks WHERE task_id = %s", (task_id,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="Task not found")
        cursor.execute("UPDATE tasks SET task = %s, done = %s WHERE task_id = %s",
                       (task.task, task.done, task_id))
        conn.commit()
        return {"task_id": task_id, "task": task.task, "done": task.done}
    except psycopg2.Error:
        conn.rollback()
        raise HTTPException(status_code=500, detail="Error updating task")

@app.delete("/tasks/{task_id}")
async def delete_task(task_id: int, api_key: str):
    await authenticate(api_key)
    try:
        cursor.execute("SELECT task_id FROM tasks WHERE task_id = %s", (task_id,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="Task not found")
        cursor.execute("DELETE FROM tasks WHERE task_id = %s", (task_id,))
        conn.commit()
        return {"task_id": task_id, "message": "Deleted successfully"}
    except psycopg2.Error:
        conn.rollback()
        raise HTTPException(status_code=500, detail="Error deleting task")

@app.get("/favicon.ico")
async def favicon():
    return {}

@app.on_event("shutdown")
async def shutdown():
    if conn:
        conn.close()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

