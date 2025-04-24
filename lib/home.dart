import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'bmi_calculator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'bmi_history.dart';
import 'locale_notifier.dart';
import 'main.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController controlWeight = TextEditingController();
  final TextEditingController controlHeight = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Nouvelle variable pour afficher les infos
  String _info = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _info = AppLocalizations.of(context)!.reportData;
  }

  void _resetFields() {
    controlHeight.text = "";
    controlWeight.text = "";
    setState(() {
      _info = AppLocalizations.of(context)!.reportData;
    });
  }

  Future<void> _calculate() async {
    if (_formKey.currentState!.validate()) {
      double weight = double.parse(controlWeight.text);
      double height = double.parse(controlHeight.text) / 100;
      double bmi = BMICalculator.calculateBMI(weight, height);

      setState(() {
        _info = BMICalculator.getBMIResult(context, bmi);
      });

      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('bmiResults').add({
          'userId': user.uid,
          'bmi': bmi,
          'resultKey': BMICalculator.getBMIResultKey(bmi),
          'timestamp': DateTime.now(),
        });
      }
    }
  }

  void _signOut() async {
    try {
      await _auth.signOut();
      if (mounted) {
        context.pushReplacement('/sign-in');
      }
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  void _refreshText() {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      if (_info == l10n.bmiUnderweight ||
          _info == l10n.bmiNormal ||
          _info == l10n.bmiOverweight ||
          _info == l10n.bmiObesity) {
        if (controlWeight.text.isNotEmpty && controlHeight.text.isNotEmpty) {
          double weight = double.parse(controlWeight.text);
          double height = double.parse(controlHeight.text) / 100;
          double bmi = BMICalculator.calculateBMI(weight, height);
          _info = BMICalculator.getBMIResult(context, bmi);
        }
      } else {
        _info = l10n.reportData;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    final l10n = AppLocalizations.of(context)!;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pushReplacement('/sign-in');
      });
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle, style: TextStyle(fontFamily: "Segoe UI")),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (Locale locale) {
              final notifier = Provider.of<LocaleNotifier>(context, listen: false);
              notifier.setLocale(locale);
              final appState = context.findRootAncestorStateOfType<MyAppState>();
              appState?.refresh();
              _refreshText(); // Mise à jour du texte _info
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: Locale('en'), child: Text('English')),
              const PopupMenuItem(value: Locale('fr'), child: Text('Français')),
              const PopupMenuItem(value: Locale('ar'), child: Text('العربية')),
            ],
          ),
          IconButton(icon: Icon(Icons.refresh), onPressed: _resetFields),
          IconButton(icon: Icon(Icons.logout), onPressed: _signOut),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.person, size: 120.0, color: Colors.green),
              TextFormField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.weightLabel,
                  labelStyle: TextStyle(color: Colors.green, fontFamily: "Segoe UI"),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green, fontSize: 25.0, fontFamily: "Segoe UI"),
                controller: controlWeight,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.insertWeightError;
                  }
                  return null;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.heightLabel,
                  labelStyle: TextStyle(color: Colors.green, fontFamily: "Segoe UI"),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green, fontSize: 25.0, fontFamily: "Segoe UI"),
                controller: controlHeight,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Insert your height!";
                  }
                  return null;
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: SizedBox(
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      textStyle: TextStyle(fontSize: 25.0, fontFamily: "Segoe UI"),
                    ),
                    child: Text(l10n.calculateButton, style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            Text(
              _info,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _info == AppLocalizations.of(context)!.reportData
                    ? Colors.green
                    : BMICalculator.getBMIColor(BMICalculator.calculateBMI(
                    double.parse(controlWeight.text),
                    double.parse(controlHeight.text) / 100
                )),
                fontSize: 25.0,
                fontFamily: "Segoe UI",
              ),
            ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: ElevatedButton(
                  onPressed: () => context.push('/history'),
                  child: Text(l10n.viewHistory),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
