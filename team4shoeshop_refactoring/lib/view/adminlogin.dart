import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:team4shoeshop_refactoring/admin/admin_main.dart';
import 'package:team4shoeshop_refactoring/dealer/dealer_main.dart';
import 'package:team4shoeshop_refactoring/view/login.dart';



class Adminlogin extends StatefulWidget {
  const Adminlogin({super.key});

  @override
  State<Adminlogin> createState() => _AdminloginState();
}

class _AdminloginState extends State<Adminlogin> {
  final TextEditingController adminIdController = TextEditingController();
  final TextEditingController adminpasswordController = TextEditingController();
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    initStorage();
  }

  void initStorage() {
    box.write('adminId', "");
    box.write('adminName', "");
    box.write('adminPermission', -1);
  }

  Future<void> loginAdmin() async {
    final id = adminIdController.text.trim();
    final pw = adminpasswordController.text.trim();

    if (id.isEmpty || pw.isEmpty) {
      errorSnackBar();
      return;
    }

    try {
      final url = Uri.parse("http://127.0.0.1:8001/employee_login");
      final request = http.MultipartRequest("POST", url);
      request.fields['eid'] = id;
      request.fields['epassword'] = pw;

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);

      if (data['result'] == 'success') {
        box.write('adminId', data['eid']);
        box.write('adminName', data['ename']);
        box.write('adminPermission', data['epermission']);

        _showDialog(data);
      } else {
        Get.snackbar(
          '로그인 실패',
          '아이디 또는 비밀번호가 올바르지 않습니다.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          colorText: Theme.of(context).colorScheme.onError,
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    } catch (e) {
      Get.snackbar("서버 오류", "로그인 요청 중 문제가 발생했습니다.");
    }
  }

  void _showDialog(Map<String, dynamic> employee) {
    Get.defaultDialog(
      title: '환영합니다',
      middleText: '신분이 확인되었습니다.',
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: ()async {
            Get.back();
             await Future.delayed(Duration(milliseconds: 200)); // 💡 딜레이 추가
            if (employee['epermission'] == 0) {
              Get.offAll(() => const DealerMain());
            } else {
              Get.offAll(() => const AdminMain());
            }
          },
          child: const Text('확인'),
        ),
      ],
    );
  }

  void errorSnackBar() {
    Get.snackbar(
      '경고',
      '관리자 ID와 암호를 입력하세요',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      colorText: Theme.of(context).colorScheme.onError,
      backgroundColor: Theme.of(context).colorScheme.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          '관리자 로그인',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
  radius: 60,
  backgroundColor: Colors.blue,
  child: Icon(Icons.person, color: Colors.white, size: 40),
),

                  // const CircleAvatar(
                  //   backgroundImage: AssetImage('images/login.png'),
                  //   radius: 60,
                  // ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: adminIdController,
                    decoration: const InputDecoration(
                      labelText: '관리자 ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: adminpasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '패스워드',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loginAdmin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Log In',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Get.off(() => const LoginPage()),
                    child: const Text(
                      '고객 로그인으로 돌아가기',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}