import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../pages/Layout.dart';
import '../../widgets/MenuLaterale.dart';
import '../../widgets/CustomSnackBar.dart';
import '../../behaviors/AppLocalizations.dart';
import 'login_controller.dart';
import 'login_form.dart';
import 'package:matchup/UI/widgets/popup/Animazione.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginLogic logic;
  final formKey = GlobalKey<FormState>();
  final nome = TextEditingController();
  final cognome = TextEditingController();
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  bool isLogin = true;
  bool isPasswordVisible = false;
  bool isLoading = false;
  bool isCheckingAuth = true;
  String livello = "Amatoriale";

  void _showError(String message) {
    CustomSnackBar.show(context, message, backgroundColor: Colors.red, textColor: Colors.white, iconColor: Colors.white);
  }
  @override
  void initState() {
    super.initState();
    logic = LoginLogic(
      FirebaseAuth.instance,
      FirebaseFirestore.instance,
    );
    _checkAuth();
  }

  Future<void> resetPassword() async {
    if (email.text.isEmpty) {
      _showError(
        AppLocalizations.of(context)!.translate("Inserisci l'email per resettare la password"),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email.text.trim(),
      );
      _showError(
        AppLocalizations.of(context)!.translate("Email di reset inviata! Controlla la posta (Cartella SPAM)."),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = AppLocalizations.of(context)!.translate("Errore nell'invio dell'email");

      if (e.code == 'user-not-found') {
        errorMessage = AppLocalizations.of(context)!.translate("Utente non trovato.");
      }
      _showError(errorMessage);
    } catch (_) {
      _showError(
        AppLocalizations.of(context)!.translate("Errore nell'invio dell'email"),
      );
    }
  }

  Future<void> _checkAuth() async {
    final logged = await logic.isUserLogged();
    if (logged && mounted) {
      await logic.updateUserCity();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Layout()),
      );
      return;
    }
    setState(() => isCheckingAuth = false);
  }

  void toggleMode() {
    setState(() {
      isLogin = !isLogin;
      nome.clear();
      cognome.clear();
      username.clear();
      email.clear();
      password.clear();
      confirmPassword.clear();
      formKey.currentState?.reset();
    });
  }

  @override
  void dispose() {
    nome.dispose();
    cognome.dispose();
    username.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();


    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        await logic.login(email.text, password.text);
      } else {
        await logic.register(
          email: email.text,
          password: password.text,
          nome: nome.text,
          cognome: cognome.text,
          username: username.text,
          livello: livello,
        );
      }

      if (mounted) {
        setState(() => isLoading = false);

        //ANIMAZIONE
        //Mostriamo il Dialog con l'animazione e aspettiamo che finisca (await)
        await showDialog(
          context: context,
          barrierDismissible: false, //L'utente non può chiuderlo cliccando fuori
          builder: (context) => const Animazione(),
        );

        //Quando il dialog si chiude, andiamo alla Home
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Layout()),
          );
        }
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Layout()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);
      String errorMessage = AppLocalizations.of(context)!.translate("Si è verificato un errore.");
      if (e.code == 'email-already-in-use') errorMessage = AppLocalizations.of(context)!.translate("Email già registrata.");
      else if (e.code == 'invalid-credential') errorMessage = AppLocalizations.of(context)!.translate("Credenziali errate.");
      else if (e.code == 'user-not-found') errorMessage = AppLocalizations.of(context)!.translate("Utente non trovato.");
      else if (e.code == 'wrong-password') errorMessage = AppLocalizations.of(context)!.translate("Password errata.");;
      _showError(errorMessage);
    } catch (e) {
      _showError(
        AppLocalizations.of(context)!
            .translate("Si è verificato un errore."),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);

    }
  }

  @override
  Widget build(BuildContext context) {
    if (isCheckingAuth) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/app_icon_splash.png',
                height: 120,
                errorBuilder: (c, e, s) => Icon(
                  Icons.sports_tennis,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 30),
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
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
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary)
      ),
      extendBodyBehindAppBar: true,
      body: LoginForm(
        formKey: formKey,
        isLogin: isLogin,
        isLoading: isLoading,
        isPasswordVisible: isPasswordVisible,
        nome: nome,
        cognome: cognome,
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        passwordFocusNode: passwordFocusNode,
        confirmPasswordFocusNode: confirmPasswordFocusNode,
        livello: livello,
        onToggleMode: toggleMode,
        onSubmit: submit,
        onTogglePassword: () => setState(() => isPasswordVisible = !isPasswordVisible),
        onLivelloChanged: (v) => setState(() => livello = v), onResetPassword: resetPassword
      ),
    );
  }
}
