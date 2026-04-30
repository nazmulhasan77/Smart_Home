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
        final profile = await _firebaseService.getUserProfile(user.uid);

        _currentUser = AppUser(
          uid: user.uid,
          email: user.email ?? profile?['email'] ?? '',
          displayName:
              profile?['displayName'] ?? user.displayName ?? 'User',
          photoUrl: profile?['photoUrl'] ?? user.photoURL,
          isGoogleUser: profile?['isGoogleUser'] ?? false,
          createdAt: profile?['createdAt'] != null
              ? (profile!['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          lastLoginAt: profile?['lastLoginAt'] != null
              ? (profile!['lastLoginAt'] as Timestamp).toDate()
              : null,
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
      _error = _mapFirebaseError(e.code);
    } catch (e) {
      _error = 'An error occurred. Please try again.';
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
      _error = _mapFirebaseError(e.code);
    } catch (e) {
      _error = 'An error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _firebaseService.signInWithGoogle();

      if (user != null) {
        _currentUser = AppUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'User',
          photoUrl: user.photoURL,
          isGoogleUser: true,
          createdAt: DateTime.now(),
        );
      }
    } on FirebaseAuthException catch (e) {
      _error = _mapFirebaseError(e.code);
    } catch (e) {
      _error = 'Google sign-in failed. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDisplayName(String newName) async {
    try {
      if (_currentUser == null) return;
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseService.updateDisplayName(_currentUser!.uid, newName);
      _currentUser = _currentUser!.copyWith(displayName: newName);
    } catch (e) {
      _error = 'Failed to update name.';
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
      _error = 'Sign out failed.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
