import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ecommerce/l10n/app_localizations.dart';
import 'dart:async';

class AuthProvider with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn();
  User? _user;
  bool _isLoading = false;
  late StreamSubscription _authStateSubscription;

  User? get user => _user;
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
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'photoUrl': userCredential.user!.photoURL,
        });
      }
    } catch (e) {
      throw _handleAuthError(e, context);
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User cancelled or an error occurred

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
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

  Future<void> _checkAndSaveUser(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'name': user.displayName,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
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
    if (e is FirebaseAuthException) {
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
    if (e is FirebaseAuthException) {
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
        await _firestore.collection('users').doc(_user!.uid).update({
          'name': newName,
        });
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
