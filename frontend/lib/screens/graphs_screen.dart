import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  String selectedSensor = "Température";

  final Map<String, List<FlSpot>> sensorData = {
    "Température": [
      FlSpot(0, 18),
      FlSpot(1, 21),
      FlSpot(2, 23),
      FlSpot(3, 20),
      FlSpot(4, 24),
      FlSpot(5, 22),
      FlSpot(6, 26),
    ],
    "Humidité": [
      FlSpot(0, 45),
      FlSpot(1, 50),
      FlSpot(2, 48),
      FlSpot(3, 53),
      FlSpot(4, 51),
      FlSpot(5, 56),
      FlSpot(6, 58),
    ],
    "Luminosité": [
      FlSpot(0, 300),
      FlSpot(1, 320),
      FlSpot(2, 310),
      FlSpot(3, 305),
      FlSpot(4, 330),
      FlSpot(5, 335),
      FlSpot(6, 340),
    ],
    "pH du sol": [
      FlSpot(0, 6.5),
      FlSpot(1, 6.7),
      FlSpot(2, 6.9),
      FlSpot(3, 7.0),
      FlSpot(4, 6.8),
      FlSpot(5, 6.6),
      FlSpot(6, 6.5),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF0B1D20) // nuit
        : const Color(0xFFEFFFEF); // vert pâle jour

    final primaryColor = isDark
        ? const Color(0xFF80E27E) // vert clair néon
        : const Color(0xFF388E3C); // vert profond

    final cardColor = isDark ? const Color(0xFF102820) : Colors.white;
    final lineColor = primaryColor;

    final data = sensorData[selectedSensor]!;

    final minY = data.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 5;
    final maxY = data.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 5;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des données"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🟩 Dropdown au centre
            Align(
              alignment: Alignment.centerLeft,
              child: DropdownButton<String>(
                value: selectedSensor,
                dropdownColor: cardColor,
                borderRadius: BorderRadius.circular(10),
                iconEnabledColor: primaryColor,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
                items: sensorData.keys.map((String key) {
                  return DropdownMenuItem<String>(value: key, child: Text(key));
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => selectedSensor = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 12),

            // 📈 Graphique
            Expanded(
              child: Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: isDark ? Colors.white12 : Colors.black12,
                          strokeWidth: 1,
                        ),
                        getDrawingVerticalLine: (_) => FlLine(
                          color: isDark ? Colors.white12 : Colors.black12,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, _) => Text(
                              "J${value.toInt() + 1}",
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) => Text(
                              value.toStringAsFixed(0),
                              style: TextStyle(
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: isDark ? Colors.white30 : Colors.black26,
                        ),
                      ),
                      minX: 0,
                      maxX: 6,
                      minY: minY,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: data,
                          isCurved: true,
                          color: lineColor,
                          barWidth: 4,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: lineColor.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
