import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'bmi_calculator.dart';
import 'locale_notifier.dart';
import 'main.dart';

class BMIHistoryScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchBMIResults() async {
    User? user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('bmiResults')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching BMI results: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bmiHistoryTitle),
        backgroundColor: Colors.green,
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (Locale locale) {
              final notifier = Provider.of<LocaleNotifier>(context, listen: false);
              notifier.setLocale(locale);

              // Get the MyAppState instance and refresh
              final appState = context.findRootAncestorStateOfType<MyAppState>();
              appState?.refresh();
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                const PopupMenuItem(
                  value: Locale('fr'),
                  child: Text('Français'),
                ),
                const PopupMenuItem(
                  value: Locale('ar'),
                  child: Text('العربية'),
                ),
              ];
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchBMIResults(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(l10n.errorLoadingData));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(l10n.noResultsFound));
          }

// In BMIHistoryScreen.dart
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var data = snapshot.data![index];

              // Vérifie que 'bmi' n'est pas null et est un nombre
              double bmi = (data['bmi'] is num) ? (data['bmi'] as num).toDouble() : 0.0;
              String resultKey = data['resultKey'] ?? '';
              String resultText = BMICalculator.getBMIResult(context, bmi);

              Timestamp? timestamp = data['timestamp'];
              String timeText = timestamp != null
                  ? timestamp.toDate().toString()
                  : l10n.unknownDate;

              return ListTile(
                title: Text("${l10n.bmi}: ${bmi.toStringAsFixed(2)}"),
                subtitle: Text("${l10n.result}: $resultText"),
                trailing: Text(
                  timeText,
                  style: const TextStyle(fontSize: 12),
                ),
                tileColor: BMICalculator.getBMIColor(bmi).withOpacity(0.2),
              );
            }
,
          );
        },
      ),
    );
  }
}