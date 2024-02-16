import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const MethodChannel _channel = MethodChannel('co.wawand/stripe');
  String _result = "Waiting...";

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _result,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                  onPressed: initialize,
                  child: const Text('Start Payment Process'))
            ],
          ),
        ),
      );

  Future<void> initialize() async {
    try {
      final arguments = {
        'stripePublishableKey': dotenv.env['DEFAULT_PUBLISHABLE_KEY'],
        'serverHost': dotenv.env['SERVER_HOST']
      };
      final String newResult = await _channel.invokeMethod('test', arguments);
      setState(() => _result = newResult);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e.message);
      }
    }
  }
}
