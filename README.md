# 🌱 AgriData IoT Platform

AgriData is an IoT-based smart agriculture monitoring system that collects sensor data via **Node-RED**, transmits it through an **MQTT broker (HiveMQ Cloud)**, stores alerts in a **PostgreSQL database**, and provides a secure **backend (Node.js + Express)** with a **Flutter mobile app frontend** for farmers to monitor and control devices.

---

## 🚀 Features

### Backend (Node.js + Express + PostgreSQL)
- User authentication (Register, Login, Logout with JWT)
- Token blacklisting for secure logout
- Secure password hashing with bcrypt
- Profile management
- Real-time MQTT integration (HiveMQ Cloud broker)
- Store and retrieve alerts (active + history)
- Control devices via MQTT publish (e.g., irrigation pumps)
- Dockerized backend with PostgreSQL

### Frontend (Flutter)
- User registration & login
- Dashboard with sensor data
- Alerts (active & history)
- Graphs & visualization of sensor data
- Settings & profile management
- Dark/Light theme toggle

### IoT & MQTT
- Node-RED flows running locally collect and process sensor data
- Data published to HiveMQ MQTT broker on topics:
  - `agri/data` → real-time sensor values
  - `agri/alerts` → alerts triggered by abnormal conditions
  - `agri/control` → commands from mobile app to actuators

---

## 🛠️ Tech Stack

- **Backend**: Node.js, Express.js, PostgreSQL, MQTT.js, JWT, Bcrypt
- **Frontend**: Flutter (Dart)
- **Database**: PostgreSQL
- **IoT**: Node-RED + HiveMQ MQTT Broker
- **DevOps**: Docker & Docker Compose
- **DevSecOps Improvements**:
  - Used environment variables for secrets (`.env` file not committed)
  - JWT blacklisting for secure logout
  - Database health checks in `docker-compose.yml`
  - Enforced CORS and HTTPS-ready deployment
  - Plan to integrate **OWASP ZAP CI/CD security scans**
  - Plan to add **Snyk / Trivy** scans for dependencies & Docker images

---

## ⚙️ Installation & Setup

### 1. Clone the repository
```bash
git clone https://github.com/your-org/AgriData.git
cd AgriData
```

### 2. Environment variables
Create a `.env` file in the root directory:
```env
# Database
DB_HOST=db
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=yourpassword
DB_NAME=agridata

# JWT
JWT_SECRET=your_jwt_secret

# MQTT
MQTT_BROKER=mqtts://broker.hivemq.com:8883
MQTT_USERNAME=your_mqtt_username
MQTT_PASSWORD=your_mqtt_password
```

### 3. Start with Docker
```bash
docker-compose up --build
```

### 4. Run frontend (Flutter app)
```bash
cd frontend
flutter pub get
flutter run
```

---

## 📡 Node-RED Setup

- Node-RED runs **locally** to collect sensor data (e.g., soil moisture, temperature, humidity).
- Data is **published to MQTT broker (HiveMQ Cloud)** on topics:
  - `agri/data` → sensor values JSON
  - `agri/alerts` → alert events JSON
- Backend subscribes to these topics and processes alerts.

Example Node-RED flow:
- Inject sensor readings (simulated or from real devices)
- MQTT out node → HiveMQ Cloud

---

## 👨‍💻 Developers  

- **Backend Developer** → [Aicha Lahnite](https://github.com/ranaitsan123)  
- **Frontend Developer** → [Ikram Amine](https://github.com/IKRAM-iN)  

---

## 📱 App Screens  

| **Login** | **Register** | **Dashboard** |  
|-----------|--------------|---------------|  
| <img width="305" height="638" src="https://github.com/user-attachments/assets/cb635f23-6660-43db-a800-67963249b500" /> | <img width="299" height="664" src="https://github.com/user-attachments/assets/dddf90d9-bbbc-49c2-8b68-eb071ba00d67" /> | <img width="340" height="731" src="https://github.com/user-attachments/assets/95f1cb20-fc91-45fc-872c-bf85a3daa438" /> |  

| **Alerts** | **History** |   |  
|------------|-------------|---|  
| <img width="278" height="611" src="https://github.com/user-attachments/assets/58c0b82f-58db-402e-b408-22824562015c" /> | <img width="279" height="576" src="https://github.com/user-attachments/assets/53a105d5-5413-4305-9c11-9ee1293646ce" /> |   |  

---

## 📂 Project Structure

```
AgriData/
├── backend/                # Node.js backend
│   ├── index.js            # Main API server
│   ├── db.js               # PostgreSQL connection
│   ├── Dockerfile
│   ├── package.json
│   └── wait-for.sh         # Wait for DB before start
├── frontend/               # Flutter app
│   ├── lib/
│   │   ├── models/         # User model
│   │   ├── providers/      # State management
│   │   ├── screens/        # UI screens
│   │   ├── services/       # API service calls
│   │   └── widgets/        # Reusable UI components
│   ├── assets/             # Images, icons
│   └── pubspec.yaml
├── docker-compose.yml      # Orchestrates backend + DB
└── README.md
```

---

## 🔮 Future Improvements

- Add role-based access control (Admin, Farmer, Technician)
- Push notifications for new alerts on mobile
- Integration with weather APIs for smarter irrigation
- AI-based prediction for crop diseases and irrigation schedules

---

## 📜 License

MIT License © 2025 AgriData Project Team
