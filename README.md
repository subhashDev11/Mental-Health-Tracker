# 🧠 Mental Health Tracker — Built on the **FFM Stack**

> Powered by **Flutter**, **FastAPI**, and **MongoDB**

![Flutter](https://img.shields.io/badge/Flutter-Web%20%26%20Mobile-blue)
![FastAPI](https://img.shields.io/badge/FastAPI-Python-green)
![MongoDB](https://img.shields.io/badge/MongoDB-Database-lightgreen)
![Built with FFM Stack](https://img.shields.io/badge/FFM%20Stack-Flutter%20%7C%20FastAPI%20%7C%20MongoDB-ff69b4)

---

A modern Mental Health Tracker app designed to help users monitor moods, maintain journals, set therapy goals, and visualize their mental health progress — all **across Web and Mobile** from a single Flutter codebase.

Built entirely on the powerful **FFM Stack** (**Flutter + FastAPI + MongoDB**), with **Pydantic** handling data modeling and validation in the backend.

---

## 🌟 The FFM Stack

| Tech          | Usage                                          |
| ------------- | ---------------------------------------------- |
| **Flutter**   | Frontend (Web, iOS, Android from one codebase) |
| **FastAPI**   | Backend API (high-performance Python web server) |
| **MongoDB**   | NoSQL Database for flexible data storage |

Additionally:
- **Pydantic** for strict and elegant data validation and management.
- **Responsive Flutter UI** optimized for mobile and web experiences.

---

## 📚 Tech Highlights

-  **FastAPI** — Super-fast Python backend
-  **Pydantic** — Clean, robust, and auto-validated data models
-  **Flutter** — Single UI codebase for Web and Mobile
-  **MongoDB** — Cloud-native NoSQL database
-  **Single Codebase** — Flutter delivers for both platforms

---

## Features

-  Mood Tracking with personal notes
-  Private Journal Entries
-  Goal Setting and Wellness Milestones
-  Mood Analytics and Visualization
-  Secure Authentication (Signup, Login)
-  Fully Responsive (Web, Mobile Devices)

---

## Screenshots-

<img width="1502" alt="Screenshot 2025-04-22 at 5 17 55 PM" src="https://github.com/user-attachments/assets/cf6593fc-2c34-4e48-80bd-f973da700b6a" />
<img width="1503" alt="Screenshot 2025-04-22 at 5 18 16 PM" src="https://github.com/user-attachments/assets/0a3f7ab6-fba0-47ad-a60f-e0cb20607d98" />
<img width="1500" alt="Screenshot 2025-04-22 at 5 18 26 PM" src="https://github.com/user-attachments/assets/f7f382d4-594d-4b79-b570-a8da1d09500a" />

<img width="488" alt="Screenshot 2025-04-22 at 5 26 54 PM" src="https://github.com/user-attachments/assets/388546c9-40ce-4861-907b-0da63424b400" />
<img width="496" alt="Screenshot 2025-04-22 at 5 27 07 PM" src="https://github.com/user-attachments/assets/5fbd14f3-7053-4760-8421-d2c05f9113e2" />
<img width="501" alt="Screenshot 2025-04-22 at 5 27 19 PM" src="https://github.com/user-attachments/assets/2ba5febd-aa77-4bed-b8b3-051a3b979ff3" />
![Simulator Screenshot - iPhone 16 Plus - 2025-04-22 at 17 30 36](https://github.com/user-attachments/assets/bf9ad1b4-f936-473b-bda3-35cac8af38c3)


---

## Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/subhashDev11/Mental-Health-Tracker.git
cd mental-health-tracker
```

### 2. Setup Backend (FastAPI + Pydantic with Poetry)
```
cd backend
# Install Poetry if not already installed
pip install poetry

# Install dependencies
poetry install

# Activate the virtual environment
poetry shell

# Run the FastAPI server
uvicorn app.main:app --reload
```

### 3. Setup Frontend (Flutter)
cd frontend
flutter pub get
flutter run -d chrome   # Run for Web
flutter run             # Run for Mobile (iOS/Android emulator or device)

### 4. Setup Environment Variables
Create a .env file inside the backend/ directory:
```env
DATABASE_URL=mongodb+srv://<username>:<password>@cluster.mongodb.net/<dbname>?retryWrites=true&w=majority
SECRET_KEY=your_secret_key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```


## ✨ Future Improvements

-  Push Notifications for daily check-ins
-  Offline Support with local storage (Flutter DB)
-  AI-based Mood and Journal Recommendations
-  More Analytics: Stress vs Sleep, Therapy Effectiveness
-  Wearable Device Integration (Fitbit, Apple Health, Google Fit)
-  Meditation & Breathing Exercises Module
-  Two-Factor Authentication (2FA) for added security

## Contributing

We welcome contributions from everyone! ❤️

If you'd like to contribute:

1. Fork the repository
2. Create a new feature branch (`git checkout -b feature/your-feature-name`)
3. Commit your changes (`git commit -m "Add your feature"`)
4. Push to the branch (`git push origin feature/your-feature-name`)
5. Open a Pull Request

You can also:
- Report bugs
- Suggest new features
- Improve documentation

Let's make this project better together! 🚀

## 🌈 Support Mental Health

Mental health matters.

By building tools like this, we empower individuals to:

- Track and understand their feelings
- Recognize patterns early
- Celebrate their emotional growth

_Keep going. Stay strong. Your story matters._ ❤️  
Together, we can make mental wellness a priority!

## Built with Love and Purpose

⸻

✅ Now everything is merged into one clean README.
✅ Professional layout — project info, setup guide, contribution, and future roadmap.
✅ Poetry used for backend installation, as you wanted.

