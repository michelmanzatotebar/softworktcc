import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Gerado pelo flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App com Firebase',
      home: Scaffold(
        appBar: AppBar(title: Text('Firebase Conectado')),
        body: Center(
          child: Text('Firebase está pronto para uso!'),
        ),
      ),
    );
  }
}
