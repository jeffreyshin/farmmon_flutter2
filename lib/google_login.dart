import 'package:farmmon_flutter/main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farmmon_flutter/social_login.dart';

class GoogleLogin implements SocialLogin {
  @override
  Future<bool> login() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);
      signinMethod = 'Google';
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      // await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut(); //For GoogleSignIn
      return true;
    } catch (error) {
      return false;
    }
  }
}

// Future<void> _signOut() async {
//   await FirebaseAuth.instance.signOut();
// }

// Future<UserCredential> signInWithGoogle() async {
//   // Trigger the authentication flow
//   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

//   // Obtain the auth details from the request
//   final GoogleSignInAuthentication? googleAuth =
//       await googleUser?.authentication;

//   // Create a new credential
//   final credential = GoogleAuthProvider.credential(
//     accessToken: googleAuth?.accessToken,
//     idToken: googleAuth?.idToken,
//   );

//   // Once signed in, return the UserCredential
//   return await FirebaseAuth.instance.signInWithCredential(credential);
// }
