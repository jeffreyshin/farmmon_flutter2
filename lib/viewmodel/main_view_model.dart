import 'package:farmmon_flutter/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farmmon_flutter/model/firebase_auth_remote_data_source.dart';
import 'package:farmmon_flutter/viewmodel/social_login.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:shared_preferences/shared_preferences.dart';

class MainViewModel {
  final _firebaseAuthDataSource = FirebaseAuthRemoteDataSource();
  final SocialLogin _socialLogin;
  bool isLoggedin = false;
  kakao.User? user;

  MainViewModel(this._socialLogin);

  Future login() async {
    isLoggedin = await _socialLogin.login();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('signinMethod', signinMethod);

    if (isLoggedin) {
      // if (signinMethod == 'Kakao') {
      user = await kakao.UserApi.instance.me();
      print("Kakao talk logged in... ");

      final token = await _firebaseAuthDataSource.createCustomToken({
        'uid': user!.id.toString(),
        'displayName': user!.kakaoAccount!.profile!.nickname,
        'email': user!.kakaoAccount!.email!,
        'photoURL': user!.kakaoAccount!.profile!.profileImageUrl!,
      });
      print("firebase: create token... ");

      await FirebaseAuth.instance.signInWithCustomToken(token);
      print("firebase: signIn with token... ");
      // }
    }
  }

  Future logout() async {
    await _socialLogin.logout();
    await FirebaseAuth.instance.signOut();
    isLoggedin = false;
    user = null;
  }
}
