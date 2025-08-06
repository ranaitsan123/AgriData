import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/theme_provider.dart';

class PremiumForgotPasswordPage extends StatefulWidget {
  const PremiumForgotPasswordPage({super.key});

  @override
  State<PremiumForgotPasswordPage> createState() =>
      _PremiumForgotPasswordPageState();
}

class _PremiumForgotPasswordPageState extends State<PremiumForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isEmailSent = false;
  String? _errorMessage;

  // Couleurs dynamiques
  Color get _primaryColor => Theme.of(context).colorScheme.primary;
  Color get _accentColor => Theme.of(context).colorScheme.secondary;
  Color get _soilColor => Theme.of(context).colorScheme.onSurface;
  Color get _cardColor => Theme.of(context).cardColor;
  Color get _errorColor => Theme.of(context).colorScheme.error;

  Future<void> _sendResetLink() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      setState(() => _errorMessage = "Veuillez entrer un email valide");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final success = await api.resetPassword(_emailController.text);
      if (success) {
        setState(() => _isEmailSent = true);
      } else {
        setState(() => _errorMessage = "Erreur lors de l'envoi du lien");
      }
    } catch (e) {
      setState(() => _errorMessage = "Erreur réseau : $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
                        // Logo et titre
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

                        // Formulaire
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
                                  _isEmailSent
                                      ? 'Lien envoyé !'
                                      : 'Mot de passe oublié',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: _soilColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _isEmailSent
                                      ? 'Un lien de réinitialisation a été envoyé à ${_emailController.text}'
                                      : 'Entrez votre email pour recevoir un lien de réinitialisation',
                                  style: TextStyle(
                                    color: _accentColor,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),

                                if (!_isEmailSent) ...[
                                  TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: TextStyle(
                                        color: _accentColor,
                                      ),
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

                                  if (_errorMessage != null) ...[
                                    Text(
                                      _errorMessage!,
                                      style: TextStyle(color: _errorColor),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : _sendResetLink,
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
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                    colorScheme.onPrimary,
                                                  ),
                                            ),
                                          )
                                        : const Text(
                                            'ENVOYER LE LIEN',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ],

                                if (_isEmailSent) ...[
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 80,
                                    color: Colors.green.shade400,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
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
                                    child: const Text(
                                      'RETOUR À LA CONNEXION',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),

                                if (!_isEmailSent)
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Retour à la connexion',
                                      style: TextStyle(color: _primaryColor),
                                    ),
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
