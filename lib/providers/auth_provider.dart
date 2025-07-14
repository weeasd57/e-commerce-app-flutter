import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;
import 'package:ecommerce/l10n/app_localizations.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:ecommerce/services/supabase_service.dart';

class AuthProvider with ChangeNotifier {
  final _auth = firebase_auth.FirebaseAuth.instance;
  final supabase.SupabaseClient _supabase = SupabaseService.client; // Use Supabase client for user data
  final _googleSignIn = google_sign_in.GoogleSignIn();
  firebase_auth.User? _user;
  bool _isLoading = false;
  late StreamSubscription _authStateSubscription;

  firebase_auth.User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _user = _auth.currentUser; // Initialize with current user status
    _authStateSubscription = _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e, context);
    }
  }

  Future<void> signIn(
      String email, String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await _checkAndSaveUser(userCredential.user!);
      }
    } catch (e) {
      throw _handleAuthError(e, context);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(
      String email, String password, String name, BuildContext context) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);

      if (userCredential.user != null) {
        // Save user data to Supabase
        await _supabase.from('users').insert({
          'uid': userCredential.user!.uid,
          'name': name,
          'email': email,
          'createdAt': DateTime.now().toIso8601String(), // Use ISO 8601 string for Supabase
          'photoUrl': userCredential.user!.photoURL,
        });
      }
    } catch (e) {
      throw _handleAuthError(e, context);
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final google_sign_in.GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User cancelled or an error occurred

      final google_sign_in.GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _checkAndSaveUser(userCredential.user!);
      }
    } catch (e) {
      throw _handleAuthError(e, context);
    }
  }

  Future<void> _checkAndSaveUser(firebase_auth.User user) async {
    // Check if user exists in Supabase and save if not
    final List<Map<String, dynamic>> users = await _supabase
        .from('users')
        .select()
        .eq('uid', user.uid);

    if (users.isEmpty) {
      await _supabase.from('users').insert({
        'uid': user.uid,
        'name': user.displayName,
        'email': user.email,
        'createdAt': DateTime.now().toIso8601String(), // Use ISO 8601 string for Supabase
        'photoUrl': user.photoURL,
      });
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  String _handleAuthError(dynamic e, BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    if (e is firebase_auth.FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return localization.userNotFound;
        case 'wrong-password':
          return localization.wrongPassword;
        case 'email-already-in-use':
          return localization.emailAlreadyInUse;
        case 'invalid-email':
          return localization.invalidEmail;
        case 'weak-password':
          return localization.weakPassword;
        case 'operation-not-allowed':
          return localization.operationNotAllowed;
        case 'user-disabled':
          return localization.userDisabled;
        default:
          return localization.anUnknownErrorOccurred;
      }
    }
    return localization.anUnknownErrorOccurred;
  }

  String getLocalizedErrorMessage(dynamic e, BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    if (e is firebase_auth.FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return localization.userNotFound;
        case 'wrong-password':
          return localization.wrongPassword;
        case 'email-already-in-use':
          return localization.emailAlreadyInUse;
        case 'invalid-email':
          return localization.invalidEmail;
        case 'weak-password':
          return localization.weakPassword;
        case 'operation-not-allowed':
          return localization.operationNotAllowed;
        case 'user-disabled':
          return localization.userDisabled;
        default:
          return localization.anUnknownErrorOccurred;
      }
    }
    return localization.anUnknownErrorOccurred;
  }

  Future<void> updateUserName(String newName) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_user != null) {
        await _user!.updateDisplayName(newName);
        // Update user name in Supabase
        await _supabase.from('users').update({'name': newName}).eq('uid', _user!.uid);
        _user = _auth.currentUser; // Refresh user data after update
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating user name: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

