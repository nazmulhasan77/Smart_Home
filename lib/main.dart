import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/firebase_options.dart';

import 'package:smart_home/providers/auth_provider.dart';
import 'package:smart_home/providers/device_provider.dart';
import 'package:smart_home/providers/schedule_provider.dart';
import 'package:smart_home/providers/theme_provider.dart';

import 'package:smart_home/screens/auth/login_screen.dart';
import 'package:smart_home/screens/auth/signup_screen.dart';
import 'package:smart_home/screens/home/device_detail_screen.dart';
import 'package:smart_home/screens/home/home_screen.dart';
import 'package:smart_home/screens/profile/profile_screen.dart';
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, DeviceProvider?>(
          create: (_) => null,
          update: (context, auth, previous) {
            if (!auth.isAuthenticated) return null;
            final userId = auth.currentUser!.uid;
            if (previous != null && previous.userId == userId) return previous;
            return DeviceProvider(userId: userId);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ScheduleProvider?>(
          create: (_) => null,
          update: (context, auth, previous) {
            if (!auth.isAuthenticated) return null;
            final userId = auth.currentUser!.uid;
            if (previous != null && previous.userId == userId) return previous;
            return ScheduleProvider(userId: userId);
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Smart Home',
            debugShowCheckedModeBanner: false,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/home': (context) => const HomeScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/schedules': (context) => const ScheduleListScreen(),
              '/device-selector': (context) => const DeviceSelectorScreen(),
              '/device-detail': (context) {
                final device =
                    ModalRoute.of(context)!.settings.arguments as Device;
                return DeviceDetailScreen(device: device);
              },
              '/add-schedule': (context) {
                final args = ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
                return AddScheduleScreen(
                  device: args['device'],
                  userId: args['userId'],
                );
              },
            },
          );
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
        // Show splash/loading while checking auth state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
