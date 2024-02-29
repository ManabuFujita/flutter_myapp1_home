import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_myapp1_home/screens/anniversaryPage.dart';
import 'package:flutter_myapp1_home/screens/home.dart';
import 'package:flutter_myapp1_home/screens/testPage.dart';
import 'package:flutter_myapp1_home/screens/todoPage.dart';
import 'package:flutter_myapp1_home/screens/zaikoPage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'firebase_options.dart';
import './screens/auth.dart';

// ユーザー情報の受け渡しを行うためのProvider
final userProvider = StateProvider((ref) {
  return FirebaseAuth.instance.currentUser;
});

final userIdProvider = StateProvider((ref) {
  final user = ref.watch(userProvider);

  return user?.uid ?? 'unknown';
});

void main() async {
  // firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDo App',
      home: user == null ? Auth() : Home(),
      routes: <String, WidgetBuilder>{
        '/auth': (BuildContext context) => Auth(),
        '/home': (BuildContext context) => Home(),
        '/todo': (BuildContext context) => TodoPage(),
        '/aniversary': (BuildContext context) => AnniversaryPage(),
        '/zaiko': (BuildContext context) => ZaikoPage(),
        '/test': (BuildContext context) => TestPage(),
      },
      // initialRoute: '/auth',
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     // SystemChrome.setSystemUIOverlayStyle(
//     //     SystemUiOverlayStyle(statusBarColor: Colors.transparent));

//     return MaterialApp(
//       // debugShowCheckedModeBanner: false,
//       title: 'ToDo App',
//       // home: Home(),
//       home: Auth(),
//     );
//   }
// }
