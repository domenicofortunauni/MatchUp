import 'package:flutter/material.dart';
import 'package:matchup/UI/pages/Layout.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/UI/widgets/CustomSnackBar.dart';
import 'package:matchup/UI/widgets/MenuLaterale.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/support/Constants.dart';
import '../../services/localizzazione.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _isLogin = true;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isCheckingAuth = true; // Per lo splash screen iniziale
  String _livello = "Amatoriale";

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }
  Future<void> _aggiornaPosizioneUtente() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final citta = await LocationService.getCurrentCity();
        await _firestore.collection('users').doc(uid).update({'citta': citta});
        print("Città aggiornata: $citta");
      }
    } catch (e) {
      print("Errore aggiornando la città: $e");
    }
  }

  // Controlla se l'utente è già loggato
  Future<void> _checkAuthStatus() async {
    await Future.delayed(Duration(milliseconds: 500)); // Piccolo ritardo per mostrare il logo
    User? user = _auth.currentUser;
    if (user != null && mounted) {
      // Utente già loggato, vai direttamente al Layout e aggiorna posizione
      _aggiornaPosizioneUtente();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Layout()),
      );

    } else {
      // Non loggato, mostra il form di login
      setState(() => _isCheckingAuth = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  void _showError(String message) {
    CustomSnackBar.show(context, message, backgroundColor: Colors.red, textColor: Colors.white, iconColor: Colors.white);
  }

  String _formatName(String text) {
    if (text.isEmpty) return "";
    String cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    return cleaned.split(' ').map((word) {
      if (word.isEmpty) return "";
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        //  LOGIN
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        try {
          _aggiornaPosizioneUtente();
        } catch (e) {
          print("Errore aggiornando la città: $e");
        }
      } else {
        //REGISTRAZIONE
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        String uid = userCredential.user!.uid;
        String nomeFormattato = _formatName(_nomeController.text);
        String cognomeFormattato = _formatName(_cognomeController.text);
        String username = _usernameController.text.trim();

        String cittaUtente = await LocationService.getCurrentCity();

        await userCredential.user!.updateDisplayName(username);

        // Salva nel Database
        await _firestore.collection('users').doc(uid).set({
          'nome': nomeFormattato,
          'cognome': cognomeFormattato,
          'username': username,
          'displayName': username,
          'email': _emailController.text.trim(),
          'uid': uid,
          'data_iscrizione': FieldValue.serverTimestamp(),
          'citta': cittaUtente,
          'livello': _livello,
        });
      }

      if (mounted) {
        setState(() => _isLoading = false);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Layout()),
          );
        }
      }

    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String errorMessage = AppLocalizations.of(context)!.translate("Si è verificato un errore.");
      if (e.code == 'email-already-in-use') errorMessage = AppLocalizations.of(context)!.translate("Email già registrata.");
      else if (e.code == 'invalid-credential') errorMessage = AppLocalizations.of(context)!.translate("Credenziali errate.");
      else if (e.code == 'user-not-found') errorMessage = AppLocalizations.of(context)!.translate("Utente non trovato.");
      else if (e.code == 'wrong-password') errorMessage = AppLocalizations.of(context)!.translate("Password errata.");;
      _showError(errorMessage);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(AppLocalizations.of(context)!.translate("Errore")+": $e");
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      _showError(AppLocalizations.of(context)!.translate("Inserisci l'email per resettare la password"));
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      _showError(AppLocalizations.of(context)!.translate("Email di reset inviata! Controlla la posta (Cartella SPAM)."));
    } catch (e) {
      _showError(AppLocalizations.of(context)!.translate("Errore nell'invio dell'email")+": $e");
    }
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> livelli = Constants.livelliKeys.map((key) {
      return {
        "key": key, // valore salvato su Firestore
        "label": AppLocalizations.of(context)!.translate(key), // testo tradotto
      };
    }).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputFillColor = isDark ? Colors.grey[900] : Colors.grey[100];
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (_isCheckingAuth) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/app_icon_splash.png',
                height: 120,
                errorBuilder: (c, e, s) => Icon(
                  Icons.sports_tennis,
                  size: 120,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 30),
              CircularProgressIndicator(
                color: primaryColor,
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      drawer: MenuLaterale(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      extendBodyBehindAppBar: true,

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'assets/images/app_icon_splash.png',
                  height: 100,
                  width: 100,
                  errorBuilder: (c,e,s) => Icon(Icons.sports_tennis, size: 100, color: primaryColor),
                ),
                const SizedBox(height: 16),

                Text(
                  _isLogin ? AppLocalizations.of(context)!.translate("Benvenuto") : AppLocalizations.of(context)!.translate("Crea account"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? AppLocalizations.of(context)!.translate("Accedi per vedere le tue statistiche.")
                      : AppLocalizations.of(context)!.translate("Unisciti a MatchUP e inizia a vincere."),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                if (!_isLogin) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nomeController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.translate("Nome"),
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
                            filled: true,
                            fillColor: inputFillColor,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          ),
                          validator: (value) {
                            if (_isLogin) return null;
                            if (value == null || value.isEmpty) return AppLocalizations.of(context)!.translate("Obbligatorio");
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _cognomeController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.translate("Cognome"),
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
                            filled: true,
                            fillColor: inputFillColor,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          ),
                          validator: (value) {
                            if (_isLogin) return null;
                            if (value == null || value.isEmpty) return AppLocalizations.of(context)!.translate("Obbligatorio");
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.translate("Username"),
                      prefixIcon: const Icon(Icons.alternate_email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
                      filled: true,
                      fillColor: inputFillColor,
                    ),
                    validator: (value) {
                      if (_isLogin) return null;
                      if (value == null || value.isEmpty) return AppLocalizations.of(context)!.translate("Inserisci un username");
                      if (value.length < 3) return AppLocalizations.of(context)!.translate("Minimo 3 caratteri");
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _livello,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.sports_tennis),
                      hintText: AppLocalizations.of(context)!.translate("Livello"),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
                      filled: true,
                      fillColor: inputFillColor,
                    ),
                    items: livelli.map((item) {
                      return DropdownMenuItem(
                        value: item["key"],
                        child: Text(item["label"]!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _livello = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Seleziona il livello";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.translate("Email"),
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
                    filled: true,
                    fillColor: inputFillColor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return AppLocalizations.of(context)!.translate("Inserisci l'email");
                    if (!value.contains('@')) return AppLocalizations.of(context)!.translate("Email non valida");
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: !_isPasswordVisible,
                  textInputAction: _isLogin ? TextInputAction.done : TextInputAction.next,
                  onFieldSubmitted: (value) {
                    if (_isLogin) {
                      _submitForm();
                    } else {
                      FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.translate("Password"),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      focusNode: FocusNode(skipTraversal: true),
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
                    filled: true,
                    fillColor: inputFillColor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return AppLocalizations.of(context)!.translate("Inserisci la password");
                    if (!_isLogin && value.length < 6) return AppLocalizations.of(context)!.translate("Minimo 6 caratteri");
                    return null;
                  },
                ),

                if (!_isLogin) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocusNode,
                    obscureText: !_isPasswordVisible,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (value) {
                      _submitForm();
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.translate("Conferma Password"),
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
                      filled: true,
                      fillColor: inputFillColor,
                    ),
                    validator: (value) {
                      if (_isLogin) return null;
                      if (value != _passwordController.text) return AppLocalizations.of(context)!.translate("Le password non coincidono");
                      return null;
                    },
                  ),
                ],

                if (_isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetPassword,
                      child: Text(AppLocalizations.of(context)!.translate("Password dimenticata?")),
                    ),
                  )
                else
                  const SizedBox(height: 24),

                if (_isLogin) const SizedBox(height: 24),

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text(
                      _isLogin ? AppLocalizations.of(context)!.translate("ACCEDI") : AppLocalizations.of(context)!.translate("CREA ACCOUNT"),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? AppLocalizations.of(context)!.translate("Non hai un account? ") : AppLocalizations.of(context)!.translate("Hai già un account? "),
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: _toggleMode,
                      child: Text(
                        _isLogin ? AppLocalizations.of(context)!.translate("Registrati") : AppLocalizations.of(context)!.translate("Accedi"),
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}