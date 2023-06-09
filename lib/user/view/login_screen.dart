import 'dart:convert';
import 'dart:io';

import 'package:delivery_app_clone_flutter/common/const/colors.dart';
import 'package:delivery_app_clone_flutter/common/layout/default_layout.dart';
import 'package:delivery_app_clone_flutter/common/view/root_tab.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../common/component/custom_text_formfield.dart';
import '../../common/const/data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String username = "";
  String password = "";

  // auth/login API, auth/token API
  @override
  Widget build(BuildContext context) {

    final dio = Dio();

    return DefaultLayout(
      // 키보드가 올라올 시 overflow가 될 수가 있으므로 overflow가 되는 제일 윗 위젯 상단에 singleChildScrollView로 만들기
      child: SingleChildScrollView(
        //  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag  = 드래그 할 시 키보드 내려감
        //  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual = 키보드 done을 해야 키보드 내려감
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Title(),
                const SizedBox(height: 16.0),
                const _SubTitle(),
                Image.asset(
                  'asset/img/misc/logo.png',
                  width: MediaQuery.of(context).size.width / 3 * 2,
                ),
                // ios 키보드 : command + shift + k
                CustomTextFormField(
                  hintText: '이메일을 입력해주세요',
                  // onChanged 텍스트 필드 값이 변화할 때마다 값을 받아와서 바꿈
                  onChanged: (value) {
                    username = value;
                  },
                ),
                const SizedBox(height: 16.0),
                CustomTextFormField(
                  hintText: '비밀번호를 입력해주세요',
                  // onChanged 텍스트 필드 값이 변화할 때마다 값을 받아와서 바꿈
                  onChanged: (value) {
                    password = value;
                  },
                  obscureText: true,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                ElevatedButton(
                  onPressed: () async {
                    // ID:비밀번호 -> Base64로 변환해야 함
                    final rawString = '$username:$password';
                    print(rawString);

                    // Codec : convert / 일반 스트링 base64로 변환
                    // 어떻게 변환할건지
                    Codec<String, String> stringToBase64 = utf8.fuse(base64);

                    // rawString 값을 변환한 token으로 저장
                    String token = stringToBase64.encode(rawString);

                    // dio post, get ...
                    final resp = await dio.post(
                      'http://$ip/auth/login',
                      options: Options(
                        headers: {
                          'authorization': 'Basic $token',
                        },
                      ),
                    );
                    // login id,pw 일치하고 api 오류가 나지 않으면 RootTab으로 이동
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RootTab(),
                      ),
                    );
                    /**token 호출하는 곳에서 RefreshToken, accessToken flutter_secure_storage 저장*/
                    // refreshToken
                    final refreshToken = resp.data['refreshToken'];
                    // accessToken
                    final accessToken = resp.data['accessToken'];

                    // storage [accessToken, refreshToken] 저장
                    await storage.write(key: REFRESH_TOKEN_KEY, value: refreshToken);
                    await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);
                  },
                  // ElevatedButton style
                  style: ElevatedButton.styleFrom(
                    primary: PRIMARY_COLOR,
                  ),
                  child: const Text('로그인'),
                ),
                TextButton(
                  onPressed: () async {

                  },
                  // TextButton Style
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                  ),
                  child: const Text('회원가입'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      '환영합니다!',
      style: TextStyle(
          fontSize: 34, fontWeight: FontWeight.w500, color: Colors.black),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      '이메일과 비밀번호를 입력해서 로그인 해주세요!\n오늘도 성공적인 주문이 되길 :)',
      style: TextStyle(fontSize: 15, color: BODY_TEXT_COLOR),
    );
  }
}
