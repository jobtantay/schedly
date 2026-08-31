import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool isLoading = false;
  String? errorMessage;

  Future<bool> signIn({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Something went wrong. Please try again.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<bool> signUp({
  required String email,
  required String password,
  required String fullName,
}) async {
  isLoading = true;
  errorMessage = null;
  notifyListeners();

  try {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
    isLoading = false;
    notifyListeners();
    return true;
  } on AuthException catch (e) {
    errorMessage = e.message;
    isLoading = false;
    notifyListeners();
    return false;
  } catch (e) {
    errorMessage = 'Something went wrong. Please try again.';
    isLoading = false;
    notifyListeners();
    return false;
  }
}

}