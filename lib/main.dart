import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:kathanote/model/auth.dart';
import 'package:kathanote/view/contacts.dart';
import 'package:kathanote/view/person_detail.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'package:kathanote/view/home.dart';
import 'package:kathanote/view/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.blueAccent,
      statusBarBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;

    return ChangeNotifierProvider(
      create: (context) => AuthWithPhonenumber(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textSelectionTheme:
              const TextSelectionThemeData(cursorColor: Colors.blueAccent),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.blueAccent.shade400,
                width: 1.5,
              ),
            ),
          ),
        ),
        initialRoute: auth.currentUser != null ? Home.route : Login.route,
        // initialRoute: auth.currentUser != null ? Home.route : Login.route,
        routes: {
          Home.route: (context) => const Home(),
          Login.route: (context) => Login(),
          ContactsPage.route: (context) => const ContactsPage(),
          PersonDetail.route: (context) => PersonDetail(),
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _askPermissions(Home.route);
  }

  Future<void> _askPermissions(String routeName) async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      Navigator.of(context).pushNamed(routeName);
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      const snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      const snackBar =
          SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts Plugin Example')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              child: const Text('Contacts list'),
              onPressed: () => _askPermissions('/contactsList'),
            ),
            ElevatedButton(
              child: const Text('Native Contacts picker'),
              onPressed: () => _askPermissions('/nativeContactPicker'),
            ),
          ],
        ),
      ),
    );
  }
}
