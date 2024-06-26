import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:voz_amiga/core/login.service.dart';
import 'package:voz_amiga/infra/services/login.service.dart';
import 'package:voz_amiga/shared/consts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginService _service;
  bool _isEmail = false;
  List<String>? _errors;

  bool _isLoading = true;
  bool _isComponentNotLoaded = true;

  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _emailRegex = RegExp(
    r"^[a-zA-Z](?:\.?[\w]+){1,}@(?:[a-zA-Z]{2,3}\.){0,2}(?:[\w]{3,20})(?:\.[a-zA-Z]{2,5}){1,2}",
  );

  @override
  void initState() {
    super.initState();
    _service = LoginService();
  }

  _checkIsLogedIn(BuildContext context) async {
    // "fix" eternal recursion doom
    if (_isComponentNotLoaded) {
      final res = await _service.isLoggedIn();
      if (res) {
        if (context.mounted) {
          context.go('/');
        }
      } else {
        setState(() {
          _isComponentNotLoaded = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signIn(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _errors = null;
    });
    final res = await _service.login(
      _loginController.text,
      _passwordController.text,
    );

    if (res.hasErrors) {
      setState(() {
        _isLoading = false;
        _errors = res.errors;
      });
    } else if (context.mounted) {
      if(res.content.isPatient){
        context.go(RouteNames.homePatient);
      }else{
        context.go(RouteNames.home);
      }
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  List<Widget> _form(BuildContext context) {
    return [
      TextFormField(
        autofocus: true,
        controller: _loginController,
        validator: (value) {
          return "Pebaasfasfsaf";
        },
        onChanged: (value) {
          final isEmail = _emailRegex.hasMatch(value);
          setState(() {
            _isEmail = isEmail;
          });
        },
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 4),
          hintText: "Ex.: 1A341DF1, medico@email.com",
          labelText: "Código/E-mail",
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      _isEmail
          ? TextFormField(
              autofocus: true,
              controller: _passwordController,
              obscureText: true,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: "Senha",
                labelStyle: TextStyle(
                  color: Color(0xFF6D6D6D),
                ),
              ),
            )
          : const SizedBox(
              height: 1,
            ),
      _errors != null
          ? Column(
              children: _errors!
                  .map(
                    (e) => Text(e, style: const TextStyle(color: Colors.red)),
                  )
                  .toList(),
            )
          : const SizedBox(
              height: 1,
            ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: ElevatedButton(
          onPressed: () {
            _signIn(context);
          },
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Entrar",
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _loadingState() {
    return const [
      Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator()],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text('Carregando...'),
          ),
        ],
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    _checkIsLogedIn(context);

    final data = _isLoading ? _loadingState() : _form(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "images/AlaskaCode.png",
                    fit: BoxFit.cover,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Voz Amiga",
                style: TextStyle(fontSize: 50),
                textAlign: TextAlign.center,
              ),
              const Text(
                "ALASKA",
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              ...data
            ],
          ),
        ),
      ),
    );
  }
}
