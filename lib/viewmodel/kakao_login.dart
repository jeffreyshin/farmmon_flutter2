import 'package:farmmon_flutter/main.dart';
import 'package:farmmon_flutter/viewmodel/social_login.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoLogin implements SocialLogin {
  @override
  Future<bool> login() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      print("kakaotalk installed: $isInstalled");
      // isInstalled = true;
      if (isInstalled) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
          signinMethod = 'Kakao';
          return true;
        } catch (e) {
          return false;
        }
      } else {
        try {
          await UserApi.instance.loginWithKakaoAccount();
          signinMethod = 'Kakao';
          return true;
        } catch (e) {
          return false;
        }
      }
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await UserApi.instance.unlink();
      return true;
    } catch (error) {
      return false;
    }
  }
}
