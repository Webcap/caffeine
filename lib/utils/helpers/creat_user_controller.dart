// import 'dart:developer';

// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';


// /// Create User ///
// class CreateUserController extends GetxController {
//   dynamic _data;

//   dynamic get data => _data;

//   Future<CreateUserModal> createUser({
//     String? email,
//     String? password,
//     int? loginType,
//     String? fcmToken,
//     String? identity,
//     String? name,
//     String? image,
//   }) async {
//     log("email : $email");
//     log("password : $password");
//     log("loginType : $loginType");
//     log("fcmToken : $fcmToken");
//     log("identity : $identity");
//     log("name : $name");
//     log("image : $image");

//     // final queryParameters = {"key": AppUrls.key};

//     final uri = Uri.parse(AppUrls.url + AppUrls.createUser);

//     log("URL :: $uri");

//     http.Response res = await http.post(
//       uri,
//       headers: {
//         "key": AppUrls.key,
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(
//         <String, dynamic>{
//           "email": email,
//           "password": password,
//           "loginType": loginType,
//           "fcmToken": fcmToken,
//           "identity": identity,
//           "fullName": name,
//           "image": image
//         },
//       ),
//     );
//     log("Response Status code :: ${res.statusCode} \nResponse Body ${res.body}");

//     SaveUser.setUser(res.body);
//     _data = jsonDecode(res.body);
//     if (res.statusCode == 200) {
//       return CreateUserModal.fromJson(_data);
//     }
//     return CreateUserModal.fromJson(_data);
//   }
// }
