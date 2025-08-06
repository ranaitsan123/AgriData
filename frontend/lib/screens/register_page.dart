import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/theme_provider.dart';

class PremiumRegisterPage extends StatefulWidget {
  const PremiumRegisterPage({super.key});

  @override
  State<PremiumRegisterPage> createState() => _PremiumRegisterPageState();
}

class _PremiumRegisterPageState extends State<PremiumRegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  // Couleurs dynamiques comme dans Login
  Color get _primaryColor => Theme.of(context).colorScheme.primary;
  Color get _accentColor => Theme.of(context).colorScheme.secondary;
  Color get _soilColor => Theme.of(context).colorScheme.onSurface;
  Color get _cardColor => Theme.of(context).cardColor;
  Color get _errorColor => Theme.of(context).colorScheme.error;

  Future<void> _register() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() => _errorMessage = "Veuillez remplir tous les champs");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = "Les mots de passe ne correspondent pas");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final success = await api.register(
        _emailController.text,
        _passwordController.text,
      );

      if (success) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        setState(() => _errorMessage = "Erreur lors de l'inscription");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                        // Logo et titre (identique à Login)
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

                        // Formulaire d'inscription
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: _cardColor.withOpacity(0.9),
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
                                  'Inscription',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: _soilColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),

                                // Email (identique à Login)
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

                                // Mot de passe (identique à Login)
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
                                const SizedBox(height: 20),

                                // Confirmation mot de passe (nouveau)
                                TextField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  decoration: InputDecoration(
                                    labelText: 'Confirmer le mot de passe',
                                    labelStyle: TextStyle(color: _accentColor),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: _primaryColor,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: _primaryColor,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
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

                                // Bouton d'inscription (style comme Login)
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _register,
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
                                          "S'INSCRIRE",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 16),

                                // Lien vers login (style comme Login)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Déjà un compte ? ',
                                      style: TextStyle(color: _accentColor),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Se connecter',
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
