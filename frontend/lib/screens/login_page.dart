import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/theme_provider.dart';

class PremiumLoginPage extends StatefulWidget {
  const PremiumLoginPage({super.key});

  @override
  State<PremiumLoginPage> createState() => _PremiumLoginPageState();
}

class _PremiumLoginPageState extends State<PremiumLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // Theming
  Color get _primaryColor => Theme.of(context).colorScheme.primary;
  Color get _accentColor => Theme.of(context).colorScheme.secondary;
  Color get _soilColor => Theme.of(context).colorScheme.onSurface;
  Color get _cardColor => Theme.of(context).cardColor;
  Color get _errorColor => Theme.of(context).colorScheme.error;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "Veuillez remplir tous les champs");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final success = await api.login(email, password);

      if (success) {
        await api.loadToken(); // Ensure token is loaded after login
        debugPrint('✅ Token after login: ${api.token}');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        setState(() => _errorMessage = "Email ou mot de passe invalide");
      }
    } catch (e) {
      setState(() => _errorMessage = "Une erreur est survenue: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(
              themeProvider.themeMode != ThemeMode.dark,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.background,
                          colorScheme.primary,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Logo & Title
                        Flexible(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.agriculture,
                                  size: 100,
                                  color: _soilColor,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'AgriConnect',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: _soilColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Form
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: _cardColor.withOpacity(0.95),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _soilColor.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Connexion',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: _soilColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),

                                // Email Field
                                TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: TextStyle(color: _accentColor),
                                    prefixIcon: Icon(
                                      Icons.email,
                                      color: _primaryColor,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    filled: true,
                                    fillColor: colorScheme.surfaceVariant
                                        .withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Password Field
                                TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Mot de passe',
                                    labelStyle: TextStyle(color: _accentColor),
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: _primaryColor,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: _primaryColor,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    filled: true,
                                    fillColor: colorScheme.surfaceVariant
                                        .withOpacity(0.5),
                                  ),
                                ),

                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage!,
                                    style: TextStyle(color: _errorColor),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                                const SizedBox(height: 24),

                                // Login Button
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryColor,
                                    foregroundColor: colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                              colorScheme.onPrimary,
                                            ),
                                          ),
                                        )
                                      : const Text(
                                          'SE CONNECTER',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 16),

                                // Footer actions
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        '/forgot-password',
                                      ),
                                      child: Text(
                                        'Mot de passe oublié ?',
                                        style: TextStyle(color: _accentColor),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        '/register',
                                      ),
                                      child: Text(
                                        'Créer un compte',
                                        style: TextStyle(color: _primaryColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
