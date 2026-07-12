import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_event_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthBloc({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        super(AuthInitial()) {
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<GoogleSignInEvent>(_onGoogleSignIn);
    on<SignOutEvent>(_onSignOut);
  }

  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password.trim(),
      );
      emit(AuthSuccess(credential.user!));
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code} - ${e.message}");
      emit(AuthFailure(_friendlyError(e.code)));
    } catch (e) {
      print("Auth Unknown Exception: $e");
      emit(AuthFailure("An unexpected error occurred: $e"));
    }
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password.trim(),
      );
      /// Set display name
      await credential.user!.updateDisplayName(event.name.trim());
      await credential.user!.reload();
      final updatedUser = _firebaseAuth.currentUser!;
      emit(AuthSuccess(updatedUser));
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code} - ${e.message}");
      emit(AuthFailure(_friendlyError(e.code)));
    } catch (e) {
      print("Auth Unknown Exception: $e");
      emit(AuthFailure("An unexpected error occurred: $e"));
    }
  }

  Future<void> _onGoogleSignIn(GoogleSignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User aborted the sign-in
        emit(AuthInitial());
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      emit(AuthSuccess(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException (Google): ${e.code} - ${e.message}");
      emit(AuthFailure(_friendlyError(e.code)));
    } catch (e) {
      print("Auth Unknown Exception (Google): $e");
      emit(AuthFailure("Google Sign-In failed. Please try again."));
    }
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    emit(AuthInitial());
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return "No account found with this email.";
      case 'wrong-password':
        return "Incorrect password. Please try again.";
      case 'invalid-email':
        return "The email address is invalid.";
      case 'email-already-in-use':
        return "An account already exists with this email.";
      case 'weak-password':
        return "Password is too weak. Use at least 6 characters.";
      case 'network-request-failed':
        return "No internet connection.";
      case 'too-many-requests':
        return "Too many attempts. Please try again later.";
      case 'invalid-credential':
        return "Invalid email or password. Please try again.";
      case 'operation-not-allowed':
        return "Email/Password sign-in is disabled in Firebase Console.";
      default:
        return "Authentication failed (Error Code: $code).";
    }
  }
}

