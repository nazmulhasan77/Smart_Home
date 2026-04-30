import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/models/user_model.dart';
import 'package:smart_home/services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _firebaseService.authStateChanges().listen((user) async {
      if (user != null) {
        // ✅ Fetch profile from Firestore for consistency
        final profile = await _firebaseService.getUserProfile(user.uid);
        
        _currentUser = AppUser(
          uid: user.uid,
          email: user.email ?? profile?['email'] ?? '',
          displayName: profile?['displayName'] ?? user.displayName ?? 'User',
          createdAt: profile?['createdAt'] != null 
              ? (profile!['createdAt'] as Timestamp).toDate() 
              : DateTime.now(),
        );
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _firebaseService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (user != null) {
        _currentUser = AppUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: displayName,
          createdAt: DateTime.now(),
        );
      }
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _firebaseService.signIn(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = AppUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'User',
          createdAt: DateTime.now(),
        );
      }
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseService.signOut();
      _currentUser = null;
    } catch (e) {
      _error = 'Sign out failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
