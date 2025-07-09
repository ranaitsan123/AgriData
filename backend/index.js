const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('./db');
const mqtt = require('mqtt');
require('dotenv').config();

const app = express();
const PORT = 5000;

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'ngrok-skip-browser-warning'],
  credentials: true,
}));

app.options('*', cors());
app.use(express.json());

// ========== DB Setup ==========

pool.query(`
  CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL
  )
`, (err) => {
  if (err) console.error('❌ DB Init Error:', err);
  else console.log('✅ Users table ready');
});

pool.query(`
  CREATE TABLE IF NOT EXISTS blacklisted_tokens (
    token TEXT PRIMARY KEY,
    expiry TIMESTAMP NOT NULL
  )
`, (err) => {
  if (err) console.error('❌ Token blacklist table error:', err);
  else console.log('✅ Token blacklist table ready');
});

pool.query(`
  CREATE TABLE IF NOT EXISTS alerts (
    id SERIAL PRIMARY KEY,
    type TEXT NOT NULL,
    message TEXT NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    sensor_data JSONB,
    handled BOOLEAN DEFAULT FALSE
  )
`, (err) => {
  if (err) console.error('❌ Alerts table error:', err);
  else console.log('✅ Alerts table ready');
});

// ========== JWT Middleware ==========

async function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Token missing' });

  try {
    const blacklisted = await pool.query(
      'SELECT 1 FROM blacklisted_tokens WHERE token = $1',
      [token]
    );

    if (blacklisted.rowCount > 0) {
      return res.status(401).json({ error: 'Token has been logged out' });
    }

    const user = jwt.verify(token, process.env.JWT_SECRET);
    req.user = user;
    next();
  } catch (err) {
    return res.status(403).json({ error: 'Invalid or expired token' });
  }
}

// ========== Auth Routes ==========

app.post('/register', async (req, res) => {
  const { username, password } = req.body;
  const hashed = await bcrypt.hash(password, 10);

  try {
    const result = await pool.query(
      'INSERT INTO users (username, password) VALUES ($1, $2) RETURNING id, username',
      [username, hashed]
    );
    console.log(`✅ User registered: ${username}`);
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('❌ Registration error:', err.message);
    res.status(400).json({ error: 'Username already exists' });
  }
});

app.post('/login', async (req, res) => {
  const { username, password } = req.body;

  const userRes = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
  const user = userRes.rows[0];

  if (!user || !(await bcrypt.compare(password, user.password))) {
    console.warn(`⚠️ Login failed for user: ${username}`);
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  const token = jwt.sign(
    { id: user.id, username: user.username },
    process.env.JWT_SECRET,
    { expiresIn: '1h' }
  );

  console.log(`✅ Login success for user: ${username}`);
  res.json({ token });
});

app.post('/logout', authenticateToken, async (req, res) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  try {
    const decoded = jwt.decode(token);
    const expiry = new Date(decoded.exp * 1000);

    await pool.query(
      'INSERT INTO blacklisted_tokens (token, expiry) VALUES ($1, $2)',
      [token, expiry]
    );

    console.log(`🚪 User ${req.user.username} logged out`);
    res.json({ message: 'Successfully logged out' });
  } catch (err) {
    console.error('❌ Logout error:', err.message);
    res.status(500).json({ error: 'Logout failed' });
  }
});

app.get('/profile', authenticateToken, async (req, res) => {
  const userRes = await pool.query(
    'SELECT id, username FROM users WHERE id = $1',
    [req.user.id]
  );
  res.json(userRes.rows[0]);
});

// ========== MQTT Setup ==========

const MQTT_BROKER = process.env.MQTT_BROKER || 'mqtts://broker.hivemq.com:8883';
const MQTT_USERNAME = process.env.MQTT_USERNAME;
const MQTT_PASSWORD = process.env.MQTT_PASSWORD;

const mqttClient = mqtt.connect(MQTT_BROKER, {
  username: MQTT_USERNAME,
  password: MQTT_PASSWORD,
  reconnectPeriod: 3000
});

let latestData = null;

mqttClient.on('connect', () => {
  console.log('🔌 Connected to HiveMQ Cloud MQTT Broker');

  mqttClient.subscribe('agri/data', (err) => {
    if (err) console.error('❌ MQTT Subscribe error (data):', err.message);
    else console.log('📡 Subscribed to topic: agri/data');
  });

  mqttClient.subscribe('agri/alerts', (err) => {
    if (err) console.error('❌ MQTT Subscribe error (alerts):', err.message);
    else console.log('📡 Subscribed to topic: agri/alerts');
  });
});

mqttClient.on('reconnect', () => console.log('🔄 Reconnecting to MQTT broker...'));
mqttClient.on('close', () => console.warn('⚠️ MQTT connection closed'));
mqttClient.on('offline', () => console.warn('📴 MQTT client is offline'));
mqttClient.on('error', (err) => console.error('❌ MQTT Error:', err.message));

mqttClient.on('message', async (topic, message) => {
  console.log(`📨 MQTT Message [${topic}]: ${message.toString()}`);

  try {
    const data = JSON.parse(message.toString());

    if (topic === 'agri/data') {
      latestData = data;
      console.log('✅ Parsed MQTT sensor data:', latestData);
    }

    if (topic === 'agri/alerts') {
      const { alerts, timestamp, sensorSnapshot } = data;

      for (const alert of alerts) {
        const result = await pool.query(
          'INSERT INTO alerts (type, message, timestamp, sensor_data) VALUES ($1, $2, $3, $4) RETURNING *',
          [alert.type, alert.message, timestamp || new Date(), sensorSnapshot || null]
        );
        console.log(`⚠️ Alert stored in DB:`, result.rows[0]);
      }
    }
  } catch (e) {
    console.error('❌ JSON parse or DB insert error:', e.message);
  }
});

// ========== Protected Sensor Data API ==========

app.get('/data', authenticateToken, (req, res) => {
  if (!latestData) {
    console.warn('⚠️ No MQTT data available');
    return res.status(404).json({ error: 'No data available yet from MQTT' });
  }
  res.json(latestData);
});

// ========== Alerts API ==========

// ✅ Get unhandled recent alerts
app.get('/alerts/active', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM alerts WHERE handled = FALSE ORDER BY timestamp DESC LIMIT 10'
    );
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Fetch active alerts error:', err.message);
    res.status(500).json({ error: 'Failed to fetch alerts' });
  }
});

// 🕓 Get all alerts (handled + unhandled)
app.get('/alerts/history', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM alerts ORDER BY timestamp DESC'
    );
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Fetch alert history error:', err.message);
    res.status(500).json({ error: 'Failed to fetch alert history' });
  }
});

// ✅ Handle alert with specific action/device and publish to MQTT
app.put('/alerts/:id', authenticateToken, async (req, res) => {
  const alertId = req.params.id;
  const { action, device } = req.body;

  if (!action || !device) {
    return res.status(400).json({ error: 'Missing action or device in request' });
  }

  try {
    // Update DB (mark as handled)
    const result = await pool.query(
      'UPDATE alerts SET handled = true WHERE id = $1 RETURNING *',
      [alertId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Alert not found' });
    }

    // Publish to MQTT → Node-RED will pick it up
    mqttClient.publish('agri/control', JSON.stringify({
      alertId,
      action,
      device,
      handledBy: req.user.username,
      timestamp: new Date().toISOString()
    }));

    console.log(`✅ Published control for ${device}: ${action}`);
    res.json(result.rows[0]);
  } catch (err) {
    console.error('❌ Error handling alert:', err.message);
    res.status(500).json({ error: 'Failed to process alert' });
  }
});


// ========== Start Server ==========

app.listen(PORT, () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
});
