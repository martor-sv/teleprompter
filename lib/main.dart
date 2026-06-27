import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/script_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TeleprompterApp());
}

class TeleprompterApp extends StatelessWidget {
  const TeleprompterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ScriptProvider()),
      ],
      child: MaterialApp(
        title: 'PromptSmart Pro 提词器',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
