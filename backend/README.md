# 🧠 Mental Health Tracker

A full-stack Mental Health Tracker app built using the **FARM Stack (FastAPI, React, MongoDB)**. This app empowers users to track their mental well-being, journal their thoughts, and visualize trends with helpful insights.

---

## 🚀 Features

-  JWT-based User Authentication (Signup/Login)
-  Daily Mood Tracker (emoji or scale)
-  Journal Entries with optional tags
-  Analytics Dashboard with charts
-  AI-generated motivational quotes or tips *(optional)*
-  Dark/Light Mode Toggle
-  Responsive Design (Mobile & Desktop)

---

## 🛠️ Tech Stack

- **Frontend**: React, TailwindCSS, React Router, Axios
- **Backend**: FastAPI, Pydantic, JWT Auth, Motor (MongoDB driver)
- **Database**: MongoDB (Local or Atlas)
- **Visualization**: Recharts.js or Chart.js

---

## 🗂 App Structure Overview

### Backend (FastAPI)
- `main.py`: App entrypoint
- `models/`: MongoDB models
- `routes/`: API endpoints (`/auth`, `/mood`, `/journal`)
- `schemas/`: Pydantic data validation
- `services/`: Business logic (e.g., authentication)
- `utils/`: JWT handling, password hashing

### Frontend (React)
- `components/`: Reusable UI elements (MoodPicker, JournalCard)
- `pages/`: Auth pages, Dashboard, Journal
- `services/`: API calls (Axios)
- `App.jsx`: Routes and layout
- `index.js`: Entry point

---

## 🧪 Getting Started

### 📦 1. Clone the Repository

```bash
git clone https://github.com/your-username/mental-health-tracker.git
cd mental-health-tracker
```

### start/stop mongo db cli

```bash

brew services start mongodb-community  
brew services stop mongodb-community  
