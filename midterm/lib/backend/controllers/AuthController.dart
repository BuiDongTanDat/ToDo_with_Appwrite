import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../appwrite_config.dart';

// Check if appwrite still saves session
Future<Map<String, Object?>> checkLoggedIn(String email) async {
  try {
    User user = await account.get();
    return {
      'code': 200,
      'response': user,
    };
  } on AppwriteException catch (e) {
    if (e.code == 401) {
      return {
        'code': e.code,
        'response': 'Unauthorized: Invalid email or password.',
      };
    } else {
      rethrow;
    }
  }
}

// Sign up
Future<Map<String, Object?>> register(
    String name, String email, String password) async {
  try {
    await account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
    return {
      'code': 201,
      'response': 'Create new user successfully.',
    }; // Created
  } on AppwriteException catch (e) {
    return {'code': e.code, 'response': e.message};
  } catch (e) {
    throw Exception("Unexpected register error: $e");
  }
}

// Login
Future<Map<String, Object?>> login(String email, String password) async {
  try {
    final session = await account.createEmailPasswordSession(
      email: email,
      password: password,
    );
    return {
      'code': 200,
      'response': session,
    };
  } on AppwriteException catch (e) {
    return {'code': e.code, 'response': e.message};
  } catch (e) {
    throw Exception("Unexpected login error: $e");
  }
}

// Logout
Future<Map<String, Object?>> logout(String email) async {
  try {
    await account.deleteSession(sessionId: 'current');
    return {
      'code': 204,
      'response': 'Session deleted successfully.',
    };
  } on AppwriteException catch (e) {
    return {'code': e.code, 'response': e.message};
  } catch (e) {
    throw Exception("Unexpected logout error: $e");
  }
}
