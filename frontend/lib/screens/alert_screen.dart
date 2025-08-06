
import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Update this path

class AlertPage extends StatefulWidget {
  final ApiService api;

  const AlertPage({super.key, required this.api});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  List<dynamic> _alerts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    setState(() => _loading = true);
    final alerts = await widget.api.getLatestAlerts();
    setState(() {
      _alerts = alerts;
      _loading = false;
    });
  }

  Future<void> _handleAlert(String id, String action, String device) async {
    final success = await widget.api.handleAlert(
      alertId: id,
      action: action,
      device: device,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Alert handled successfully')),
      );
      await _fetchAlerts();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ Failed to handle alert')));
    }
  }

  /// Dynamically generate action chips based on alert type
  List<Widget> _buildActionChips(Map<String, dynamic> alert) {
    final type = alert['type'].toString().toLowerCase();
    final id = alert['id'].toString();
    final List<Widget> chips = [];

    if (type.contains('soil') || type.contains('moisture')) {
      chips.add(
        _buildActionChip(
          id,
          'Irriguer',
          'irrigation_pump',
          Icons.water_drop,
          Colors.blue,
        ),
      );
    }
    if (type.contains('temp')) {
      chips.add(
        _buildActionChip(id, 'Ventiler', 'fan', Icons.air, Colors.teal),
      );
    }
    if (type.contains('humidity')) {
      chips.add(
        _buildActionChip(
          id,
          'Brumiser',
          'humidifier',
          Icons.cloud,
          Colors.indigo,
        ),
      );
    }
    if (type.contains('co2')) {
      chips.add(
        _buildActionChip(
          id,
          'Ventiler CO₂',
          'exhaust_fan',
          Icons.air_outlined,
          Colors.orange,
        ),
      );
    }

    // Fallback action
    if (chips.isEmpty) {
      chips.add(
        _buildActionChip(
          id,
          'Inspecter',
          'camera',
          Icons.camera_alt,
          Colors.grey,
        ),
      );
    }

    return chips;
  }

  Widget _buildActionChip(
    String id,
    String label,
    String device,
    IconData icon,
    Color color,
  ) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      onPressed: () => _handleAlert(id, 'ACTIVATE', device),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertes actives')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchAlerts,
              child: _alerts.isEmpty
                  ? const Center(child: Text('✅ Aucune alerte active'))
                  : ListView.builder(
                      itemCount: _alerts.length,
                      itemBuilder: (context, index) {
                        final alert = _alerts[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alert['type'],
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(alert['message']),
                                const SizedBox(height: 8),
                                Text(
                                  alert['timestamp'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const Divider(height: 20),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: _buildActionChips(alert),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
