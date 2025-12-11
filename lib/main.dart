// ignore_for_file: avoid_print

import 'dart:ui';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zimax/src/auth/signin.dart';
import 'package:zimax/src/pages/extrapage.dart/chat_item_hive.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("Background Message: ${message.messageId}");
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp();

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // await FirebaseMessaging.instance.requestPermission(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );

  // String? token = await FirebaseMessaging.instance.getToken();
  // print("FCM Token: $token");

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print("Foreground message: ${message.notification?.title}");
  // });

  // FirebaseMessaging.onMessageOpenedApp.listen((message) {
  //   print("Opened from notification");
  // });

  // RemoteMessage? initialMessage = await FirebaseMessaging.instance
  //     .getInitialMessage();

  // if (initialMessage != null) {
  //   print("App opened from terminated state via notification");
  //   print("Title: ${initialMessage.notification?.title}");
  // }

  // final FlutterLocalNotificationsPlugin notifications =
  //     FlutterLocalNotificationsPlugin();

  // await notifications.initialize(
  //   const InitializationSettings(
  //     android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  //     iOS: DarwinInitializationSettings(),
  //   ),
  // );

  // FirebaseMessaging.onMessage.listen((message) {
  //   notifications.show(
  //     0,
  //     message.notification?.title,
  //     message.notification?.body,
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'channel_id',
  //         'General Notifications',
  //         importance: Importance.high,
  //         priority: Priority.high,
  //       ),
  //     ),
  //   );
  // });
  // final supabase = Supabase.instance.client;
  // await supabase.from('device_tokens').upsert({
  //   'user_id': supabase.auth.currentUser!.id,
  //   'token': token,
  // });

  final dir = await getApplicationDocumentsDirectory();

  await Hive.initFlutter(dir.path);

  Hive.registerAdapter(ChatItemHiveAdapter());

  await Hive.openBox<ChatItemHive>('chatlist');

  await Supabase.initialize(
    url: 'https://kldaeoljhumowuegwjyq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtsZGFlb2xqaHVtb3d1ZWd3anlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ4OTY2MjAsImV4cCI6MjA4MDQ3MjYyMH0.OrqMl6ejtoa8m41Y1MWJm1oAz3S3iKc0UXlW07qyG3A',
  );

  final box = await Hive.openBox('chat_items');  
  await box.close();  


  runApp(
    const ProviderScope(
      child: MaterialApp(debugShowCheckedModeBanner: false, home: Zimax()),
    ),
  );
}

class Zimax extends StatefulWidget {
  const Zimax({super.key});

  @override
  State<Zimax> createState() => _ZimaxState();
}

class _ZimaxState extends State<Zimax> {
  @override
  void initState() {
    super.initState();

    // Wait 5 seconds then navigate
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Signin()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bgimg1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Bottom overlay panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(25),
              height: size.height * 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Color.fromARGB(82, 0, 0, 0),
                    Color.fromARGB(240, 0, 0, 0),
                  ],
                  stops: [0.0, 0.0, 0.5, 1.0],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/logo.png'),
                          // fit: BoxFit.contain
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Zimax',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Text(
                        "Communication and Information dispersal at it's finest",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {},
                      child: SizedBox(
                        height: 35,
                        width: 35,
                        child: LoadingAnimationWidget.threeArchedCircle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          size: 35,
                        ),
                      ),
                    ),
                    SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
