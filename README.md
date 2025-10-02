# ✅ To-Do List App
<img src="banner/To DO App.jpg" alt="Project Banner with Mockups" style="max-width: 1000px; width: 100%; height: auto; display: block; margin: 0 auto;" />

A simple and efficient To-Do list app built using **Flutter** for the frontend and **FastAPI** for the backend.

## 📱 Features
- Add, delete, and mark tasks as completed
- Local storage using `shared_preferences`
- State management with `provider`
- API communication with `dio`
- Backend with FastAPI for task persistence

## 🛠 Tech Stack
- **Frontend**: Flutter
  - `provider`
  - `dio`
  - `shared_preferences`
- **Backend**: FastAPI (Python)

## 🚀 Getting Started

### Backend Setup (FastAPI)
```bash
pip install fastapi uvicorn
uvicorn main:app --reload
