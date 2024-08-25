import 'package:chat/screens/chatscreen.dart';
import 'package:chat/screens/homescreen.dart';
import 'package:chat/screens/login_page.dart';
import 'package:chat/screens/signup_page.dart';
import 'package:chat/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
   theme: ThemeData(
     appBarTheme: AppBarTheme(
       color: Color(0xFF2c7bb6),
     )
   ),
    initialRoute: '/signup',
      routes: {
        '/login' : (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/home' : (context) => HomeScreen(),
        '/chat' : (context) => ChatScreen(receiverName: '', receiverId: '',),

      },

    );
  }
}
