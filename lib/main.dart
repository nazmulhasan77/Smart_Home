import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/firebase_options.dart';

import 'package:smart_home/providers/auth_provider.dart';
import 'package:smart_home/providers/device_provider.dart';

import 'package:smart_home/screens/auth/login_screen.dart';
import 'package:smart_home/screens/auth/signup_screen.dart';
import 'package:smart_home/screens/home/device_detail_screen.dart';
import 'package:smart_home/screens/home/home_screen.dart';
import 'package:smart_home/screens/schedule/add_schedule_screen.dart';
import 'package:smart_home/screens/schedule/device_selector_screen.dart';
import 'package:smart_home/screens/schedule/schedule_list_screen.dart';

import 'package:smart_home/models/device_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // ✅ FIXED: no hardcoded UID
        ChangeNotifierProvider(create: (_) => DeviceProvider(userId: '')),
      ],
      child: MaterialApp(
        title: 'Smart Home Control',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/schedules': (context) => const ScheduleListScreen(),
          '/device-selector': (context) => const DeviceSelectorScreen(),

          '/device-detail': (context) {
            final device = ModalRoute.of(context)!.settings.arguments as Device;
            return DeviceDetailScreen(device: device);
          },

          '/add-schedule': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
            return AddScheduleScreen(
              device: args['device'],
              userId: args['userId'],
            );
          },
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.isAuthenticated) {
          final uid = authProvider.currentUser!.uid;

          // ✅ SAFE UID injection
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<DeviceProvider>().setUser(uid);
          });

          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
