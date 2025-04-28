import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../appwrite_config.dart';
import '../appwrite_config.dart' as AppwriteClient;

// Sign up
Future<String> register(String name, String email, String password) async {
  try {
    final user = await account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
    return '✅ 201';
  } on AppwriteException catch (e) {
    return '❌ AppwriteException: ${e.message}';
  } catch (e) {
    return '❌ Other error: $e';
  }
}

// Login
Future<Session?> login(String email, String password) async {
  // await logout();

  try {
    final session = await account.createEmailPasswordSession(
      email: email,
      password: password,
    );

    // await account.createVerification(
    //   url: 'http://10.0.2.2:3000/verify',
    // );

    return session;
  } on AppwriteException catch (e) {
    throw Exception("❌ Appwrite login failed: ${e.message}");
  } catch (e) {
    throw Exception("❌ Unexpected login error: $e");
  }
}

Future<void> logout() async {
  try {
    // Check if user is logged in
    final user = await account.get();
    await account.deleteSession(sessionId: 'current');
  } on AppwriteException catch (e) {
    print('❌ Logout error: ${e.message}');
  }
}

// Future<String> sendVerificationMail() async {
//   try {
//     await AppwriteClient.account.createVerification(
//       url: 'https://yourdomain.com/verification-success',
//     );
//     return '✅ Verification email sent!';
//   } on AppwriteException catch (e) {
//     return '❌ Error sending verification: ${e.message}';
//   }
// }

Future<void> verify({required String userId, required String secret}) async {
  try {
    await AppwriteClient.account.updateVerification(
      userId: userId,
      secret: secret,
    );
    print('✅ Email verified successfully!');
  } on AppwriteException catch (e) {
    print('❌ Email verification failed: ${e.message}');
  }
}
