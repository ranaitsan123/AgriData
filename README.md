# 🌱 AgriData – IoT Smart Agriculture Platform  

AgriData is an IoT-based smart agriculture solution that collects real-time sensor data, detects anomalies, and provides farmers with alerts and control capabilities. The system integrates an **Express.js backend**, **PostgreSQL database**, **MQTT broker (HiveMQ)**, **Node-RED for IoT data flow**, and a **Flutter mobile app** frontend.  

---

## 🚀 Features  

### 📡 IoT Integration  
- Real-time sensor data collection via **MQTT** (`agri/data` topic).  
- Alerts published via **MQTT** (`agri/alerts` topic).  
- Control actions sent back to IoT devices (`agri/control` topic).  

### 🔐 Authentication  
- User registration & login with **JWT tokens**.  
- Logout with **token blacklisting** for security.  
- Protected APIs requiring authentication.  

### 📊 Backend APIs  
- **/register** → Create account.  
- **/login** → Authenticate user and receive token.  
- **/logout** → Blacklist current token.  
- **/profile** → Fetch user profile.  
- **/data** → Get latest real-time sensor data.  
- **/alerts/active** → Get latest unhandled alerts.  
- **/alerts/history** → Get full alerts history.  
- **/alerts/:id** → Mark alert as handled & publish control command.  

### 📱 Mobile App (Flutter)  
- Login / Register screens.  
- Real-time dashboard with sensor readings.  
- Graphs and history visualization.  
- Alerts with ability to send control actions.  
- Light/dark theme support.  

---

## 🏗️ Project Structure  

```
AgriData/
├── backend/                 # Node.js + Express backend
│   ├── index.js             # Main server
│   ├── db.js                # PostgreSQL connection
│   ├── Dockerfile           # Backend container
│   ├── package.json
│   └── wait-for.sh
├── frontend/                # Flutter mobile app
│   ├── lib/
│   │   ├── models/          # Data models (User)
│   │   ├── providers/       # Theme provider
│   │   ├── screens/         # UI pages (login, dashboard, alerts, etc.)
│   │   ├── services/        # API service (REST calls to backend)
│   │   └── widgets/         # Reusable UI components
│   ├── pubspec.yaml
│   └── README.md
├── docker-compose.yml       # Multi-service setup
└── .env                     # Environment variables
```

---

## 🌐 System Architecture  

```
   ┌─────────────┐        MQTT         ┌──────────────┐
   │   Node-RED  │  ─────────────────▶ │  HiveMQ Cloud │
   │ (Local IoT) │   agri/data,alerts  │   Broker      │
   └─────────────┘                     └───────▲──────┘
                                                │
                                     agri/control│
                                                │
                                        ┌───────┴──────┐
                                        │   Backend    │
                                        │ (Express.js) │
                                        └───────▲──────┘
                                                │ REST API
                                                │
                                       ┌────────┴─────────┐
                                       │   Flutter App    │
                                       │ (Android/iOS)    │
                                       └──────────────────┘
```

### Explanation  
- **Node-RED (Local)**: Collects sensor data (simulated or real) and publishes to MQTT topics (`agri/data`, `agri/alerts`).  
- **HiveMQ Cloud Broker**: Acts as the messaging hub between IoT devices, backend, and control commands.  
- **Backend (Express.js)**: Subscribes to broker topics, stores alerts in PostgreSQL, and exposes secure REST APIs.  
- **Flutter App**: Fetches sensor data, alert history, and allows the user to send **control actions**, which get published back to Node-RED through the broker (`agri/control`).  

---

## ⚙️ Technologies  

- **Backend**: Node.js (Express.js), PostgreSQL, JWT, Bcrypt, MQTT.js  
- **Frontend**: Flutter (Dart), SharedPreferences, HTTP  
- **Database**: PostgreSQL 15 (Dockerized)  
- **Messaging**: MQTT (HiveMQ Cloud, Node-RED local publisher)  
- **Deployment**: Docker, Docker Compose  
- **Extras**: Ngrok (for tunneling backend API)  

---

## 🛠️ Setup Instructions  

### 1. Clone repository  
```bash
git clone https://github.com/your-username/AgriData.git
cd AgriData
```

### 2. Configure Environment Variables  
Create a `.env` file in the project root:  
```env
# Database
DB_HOST=db
DB_PORT=5432
DB_USER=youruser
DB_PASSWORD=yourpassword
DB_NAME=agridata

# JWT
JWT_SECRET=supersecretjwt

# MQTT
MQTT_BROKER=mqtts://broker.hivemq.com:8883
MQTT_USERNAME=your-hivemq-username
MQTT_PASSWORD=your-hivemq-password
```

### 3. Run with Docker Compose  
```bash
docker-compose up --build
```
- Backend → http://localhost:5000  
- Database → localhost:5432  

### 4. Run Frontend (Flutter App)  
```bash
cd frontend
flutter pub get
flutter run
```

---

## 📱 API Examples  

**Register User**  
```bash
POST /register
{
  "username": "farmer1",
  "password": "mypassword"
}
```

**Login**  
```bash
POST /login
{
  "username": "farmer1",
  "password": "mypassword"
}
```

**Get Sensor Data**  
```bash
GET /data
Authorization: Bearer <token>
```

---

## 🔮 Future Improvements  

- AI-based predictive irrigation system.  
- Role-based access control (admin, farmer, technician).  
- Multi-language support in the app.  
- GraphQL API support.  
- Integration with cloud IoT platforms (AWS IoT, Azure IoT Hub).  
- **DevSecOps pipeline**: Automate CI/CD with integrated security checks (linting, unit tests, dependency scanning, vulnerability scanning with tools like **OWASP ZAP**, **Snyk**, or **Trivy**) to ensure secure and reliable deployments.  

---

## 👩‍💻 Author  

Developed by **Aicha** 🌸  
Passionate about IoT, Cloud Computing, and Cybersecurity.  
