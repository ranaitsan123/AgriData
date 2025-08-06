import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ApiService apiService = ApiService();

  List<dynamic> alertHistory = [];
  bool isLoading = true;

  String? selectedDate;
  bool showHandled = true; // true = show handled alerts, false = unhandled

  final Color _primaryColor = const Color(0xFF4CAF50);
  final Color _soilColor = const Color(0xFF795548);
  final Color _skyColor = const Color(0xFFB3E5FC);
  final Color _backgroundColor = const Color(0xFFE8F5E9);
  final Color _darkBackground = const Color(0xFF0B1D20);
  final Color _darkCard = const Color(0xFF1F3D2B);

  @override
  void initState() {
    super.initState();
    _fetchAlertHistory();
  }

  Future<void> _fetchAlertHistory() async {
    await apiService.loadToken();
    final data = await apiService.getAlertHistory();
    setState(() {
      alertHistory = data;
      isLoading = false;
    });
  }

  String _translateAction(String device) {
    switch (device) {
      case 'irrigation_pump':
        return 'Irriguer';
      case 'fan':
        return 'Ventiler';
      case 'light':
        return 'Éclairage';
      case 'camera':
        return 'Caméra';
      default:
        return device;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredData = alertHistory.where((item) {
      final dateStr = item['timestamp']?.substring(0, 10);
      final matchDate = selectedDate == null || dateStr == selectedDate;
      final matchStatus = item['handled'] == showHandled;
      return matchDate && matchStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: "Filtrer par date",
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2024, 1, 1),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  selectedDate = DateFormat('yyyy-MM-dd').format(picked);
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: "Réinitialiser le filtre",
            onPressed: () {
              setState(() {
                selectedDate = null;
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? null
              : LinearGradient(
                  colors: [_skyColor, _backgroundColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
          color: isDark ? _darkBackground : null,
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !showHandled
                                  ? Colors.orange[100]
                                  : Colors.white,
                              foregroundColor: Colors.orange[800],
                            ),
                            icon: const Icon(Icons.warning_amber),
                            label: const Text("Non traitées"),
                            onPressed: () {
                              setState(() {
                                showHandled = false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: showHandled
                                  ? Colors.green[100]
                                  : Colors.white,
                              foregroundColor: Colors.green[800],
                            ),
                            icon: const Icon(Icons.check_circle),
                            label: const Text("Traitées"),
                            onPressed: () {
                              setState(() {
                                showHandled = true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: filteredData.isEmpty
                        ? const Center(
                            child: Text(
                              "Aucune alerte correspondante",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredData.length,
                            itemBuilder: (context, index) {
                              final item = filteredData[index];
                              final title = item['type'] ?? 'Alerte';
                              final message = item['message'] ?? '';
                              final date =
                                  item['timestamp']
                                      ?.substring(0, 19)
                                      ?.replaceAll('T', ' ') ??
                                  '';
                              final handled = item['handled'] ?? false;
                              final device = item['device'] ?? '';
                              final translatedAction = _translateAction(device);

                              final iconName = _mapTypeToIcon(title);
                              final chipLabel = handled
                                  ? '✅ Action : $translatedAction'
                                  : '⏳ Non traité';

                              return Card(
                                color: isDark ? _darkCard : Colors.white,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            _getIcon(iconName),
                                            color: _primaryColor,
                                            size: 30,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: isDark
                                                    ? Colors.white
                                                    : _soilColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        message,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        date,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Chip(
                                        label: Text(chipLabel),
                                        backgroundColor: handled
                                            ? Colors.green[100]
                                            : Colors.orange[100],
                                        labelStyle: TextStyle(
                                          color: handled
                                              ? Colors.green[800]
                                              : Colors.orange[800],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  IconData _getIcon(String? name) {
    switch (name) {
      case 'water_drop':
        return Icons.water_drop;
      case 'grass':
        return Icons.grass;
      case 'healing':
        return Icons.healing;
      case 'compost':
        return Icons.eco;
      default:
        return Icons.history;
    }
  }

  String _mapTypeToIcon(String? type) {
    final t = type?.toLowerCase() ?? '';
    if (t.contains('eau') || t.contains('arrosage') || t.contains('moisture'))
      return 'water_drop';
    if (t.contains('récolte') || t.contains('culture')) return 'grass';
    if (t.contains('traitement') || t.contains('phytosanitaire'))
      return 'healing';
    if (t.contains('engrais') || t.contains('compost')) return 'compost';
    return 'default';
  }
}
