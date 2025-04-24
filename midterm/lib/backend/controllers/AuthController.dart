import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../appwrite_config.dart';

// Register
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
  await logout();

  try {
    final session = await account.createEmailPasswordSession(
      email: email,
      password: password,
    );
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
