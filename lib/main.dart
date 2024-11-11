import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:instagram_clone/providers/user_providers.dart';
import 'package:instagram_clone/responsive/mobileScreen_layout.dart';
import 'package:instagram_clone/responsive/responsive_layout_screen.dart';
import 'package:instagram_clone/responsive/webScreen_layout.dart';
import 'package:instagram_clone/screens/login_screens.dart';
import 'package:instagram_clone/screens/signup_screen.dart';
import 'package:instagram_clone/utilis/colors.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAhB5WTeS3jLW4Jh1MDE3Z8AGGM4KgsDtw",
            authDomain: "tiktokclone-da8f4.firebaseapp.com",
            projectId: "tiktokclone-da8f4",
            storageBucket: "tiktokclone-da8f4.appspot.com",
            messagingSenderId: "1044314579932",
            appId: "1:1044314579932:web:311c754f69b4d464d4e519"));
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Instagram Clone',
          theme: ThemeData.dark()
              .copyWith(scaffoldBackgroundColor: mobileBackgroundColor),
          home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    return const ResponsiveLayoutScreen(
                        mobileScreenLayout: MobilescreenLayout(),
                        webScreenLayout: WebscreenLayout());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('fffffffffffffffffffffffff'),
                    );
                  }
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: primaryColor,
                  ));
                }

                return const LoginScreen();
              })),
    );
  }
}
