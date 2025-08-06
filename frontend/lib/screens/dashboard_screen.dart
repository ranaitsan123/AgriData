import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import '../services/api_service.dart';
import '../providers/theme_provider.dart';

class PremiumDashboardScreen extends StatefulWidget {
  const PremiumDashboardScreen({super.key});

  @override
  State<PremiumDashboardScreen> createState() => _PremiumDashboardScreenState();
}

class _PremiumDashboardScreenState extends State<PremiumDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final Map<String, Map<String, dynamic>> sensorData = {
    'Température': {'value': '--', 'trend': 0, 'unit': '°C'},
    'Humidité': {'value': '--', 'trend': 0, 'unit': '%'},
    'Luminosité': {'value': '--', 'trend': 0, 'unit': 'lx'},
    'CO2': {'value': '--', 'trend': 0, 'unit': 'ppm'},
    'Humidité Sol': {'value': '--', 'trend': 0, 'unit': '%'},
  };

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool hasNewAlerts = true;

  Color get _primaryColor => Theme.of(context).colorScheme.primary;
  Color get _accentColor => Theme.of(context).colorScheme.secondary;
  Color get _surfaceColor => Theme.of(context).colorScheme.surface;
  Color get _onSurfaceColor => Theme.of(context).colorScheme.onSurface;
  Color get _background => Theme.of(context).colorScheme.background;
  Color get _errorColor => Theme.of(context).colorScheme.error;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
      ),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      _loadSensorData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSensorData() async {
    setState(() => _isLoading = true);
    final api = Provider.of<ApiService>(context, listen: false);

    try {
      final response = await api.getSensorData();

      if (response != null) {
        setState(() {
          sensorData['Température'] = {
            'value': '${response['temperature']}°C',
            'trend': response['tempTrend'],
            'unit': '°C',
          };
          sensorData['Humidité'] = {
            'value': '${response['humidity']}%',
            'trend': response['humidityTrend'],
            'unit': '%',
          };
          sensorData['Humidité Sol'] = {
            'value': '${response['soilMoisture']}%',
            'trend': response['soilMoistureTrend'],
            'unit': '%',
          };
          sensorData['Luminosité'] = {
            'value': '${response['light']} lx',
            'trend': response['lightTrend'],
            'unit': 'lx',
          };
          sensorData['CO2'] = {
            'value': '${response['co2']} ppm',
            'trend': response['co2Trend'],
            'unit': 'ppm',
          };
        });
      } else {
        _showErrorSnackbar('Impossible de charger les données du capteur.');
      }
    } catch (e) {
      _showErrorSnackbar('Erreur : $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await _loadSensorData();
    setState(() => _isRefreshing = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Données actualisées'),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Tableau de bord AgriTech'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _primaryColor.withOpacity(0.8),
                _primaryColor,
                _primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        elevation: 10,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () => themeProvider.toggleTheme(
              themeProvider.themeMode != ThemeMode.dark,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _refreshData,
            tooltip: 'Actualiser',
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/alertes'),
              ),
              if (hasNewAlerts)
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              api.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      drawer: _buildDrawer(isDarkMode),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(_primaryColor),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: _primaryColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statistiques des capteurs',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _onSurfaceColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dernière mise à jour: ${DateTime.now().toString().substring(0, 16)}',
                          style: TextStyle(
                            color: _onSurfaceColor.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...sensorData.entries.map(
                          (entry) => _buildSensorCard(entry.key, entry.value),
                        ),
                        const SizedBox(height: 24),
                        _buildQuickActionsCard(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        backgroundColor: _primaryColor,
        child: _isRefreshing
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              )
            : const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildDrawer(bool isDarkMode) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [Colors.grey.shade900, Colors.grey.shade800]
                : [Colors.white, const Color(0xFFE8F5E9)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(isDarkMode),
            _buildDrawerItem(Icons.dashboard, 'Dashboard', true, () {}),
            _buildDrawerItem(Icons.show_chart, 'Graphiques', false, () {
              Navigator.pushNamed(context, '/graphs');
            }),
            _buildDrawerItem(Icons.history, 'Historique', false, () {
              Navigator.pushNamed(context, '/history');
            }),
            _buildDrawerItem(Icons.notifications, 'Alertes', false, () {
              Navigator.pushNamed(context, '/alertes');
            }),
            _buildDrawerItem(Icons.settings, 'Paramètres', false, () {
              Navigator.pushNamed(context, '/settings');
            }),
            const Divider(),
            _buildDrawerItem(Icons.help, 'Aide', false, () {}),
            _buildDrawerItem(Icons.info, 'À propos', false, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(bool isDarkMode) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_primaryColor.withOpacity(0.8), _primaryColor],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Colors.green),
          ),
          const SizedBox(height: 16),
          const Text(
            'John Doe',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'john.doe@agritech.com',
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? _primaryColor : _accentColor),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? _onSurfaceColor : _accentColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: onTap,
    );
  }

  Widget _buildSensorCard(String key, Map<String, dynamic> data) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final trend = data['trend'] as int;
    final iconData = _getIconForSensor(key);
    final iconColor = _getColorForSensor(key);

    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showSensorDetails(key, data),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      key,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : _onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getTrendIcon(trend),
                          color: _getTrendColor(trend),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trend == 1
                              ? "En hausse"
                              : trend == -1
                              ? "En baisse"
                              : "Stable",
                          style: TextStyle(
                            color: _getTrendColor(trend),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                data['value'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : _onSurfaceColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionChip(
                  icon: Icons.water_drop,
                  color: Colors.blue,
                  label: 'Irriguer',
                ),
                _buildActionChip(
                  icon: Icons.light_mode,
                  color: Colors.amber,
                  label: 'Éclairage',
                ),
                _buildActionChip(
                  icon: Icons.air,
                  color: _accentColor,
                  label: 'Ventilation',
                ),
                _buildActionChip(
                  icon: Icons.camera_alt,
                  color: _primaryColor,
                  label: 'Caméra',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ActionChip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
      ),
      backgroundColor: isDarkMode
          ? Colors.grey.shade700
          : color.withOpacity(0.1),
      onPressed: () {},
    );
  }

  void _showSensorDetails(String sensor, Map<String, dynamic> data) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                sensor,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : _onSurfaceColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailTile(
                icon: _getIconForSensor(sensor),
                iconColor: _getColorForSensor(sensor),
                title: 'Valeur actuelle',
                value: data['value'],
              ),
              _buildDetailTile(
                icon: _getTrendIcon(data['trend']),
                iconColor: _getTrendColor(data['trend']),
                title: 'Tendance',
                value: data['trend'] == 1
                    ? "En hausse"
                    : data['trend'] == -1
                    ? "En baisse"
                    : "Stable",
              ),
              _buildDetailTile(
                icon: Icons.straighten,
                iconColor: _accentColor,
                title: 'Unité',
                value: data['unit'],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(fontWeight: FontWeight.bold, color: _primaryColor),
      ),
    );
  }

  IconData _getIconForSensor(String sensor) {
    switch (sensor) {
      case 'Température':
        return Icons.thermostat;
      case 'Humidité':
        return Icons.opacity;
      case 'Luminosité':
        return Icons.wb_sunny;
      case 'CO2':
        return Icons.co2;
      case 'Humidité Sol':
        return Icons.grass;
      default:
        return Icons.device_unknown;
    }
  }

  Color _getTrendColor(int trend) {
    if (trend > 0) return Colors.green.shade600;
    if (trend < 0) return Colors.red.shade600;
    return _accentColor;
  }

  IconData _getTrendIcon(int trend) {
    if (trend > 0) return Icons.trending_up;
    if (trend < 0) return Icons.trending_down;
    return Icons.trending_flat;
  }

  Color _getColorForSensor(String sensor) {
    switch (sensor) {
      case 'Température':
        return Colors.orange.shade600;
      case 'Humidité':
        return Colors.blue.shade600;
      case 'Luminosité':
        return Colors.yellow.shade700;
      case 'CO2':
        return _primaryColor;
      case 'Humidité Sol':
        return const Color(0xFF795548);
      default:
        return _accentColor;
    }
  }
}
