import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart'; // ✅ 这是必须的



// TODO(codelab user): Get API key
const clientId = 'YOUR_CLIENT_ID';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
