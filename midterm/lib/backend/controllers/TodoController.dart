import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:midterm/backend/controllers/AuthController.dart';
import 'package:midterm/model/TodoModel.dart';
import '../appwrite_config.dart';

Future<List<Document>> getTodos() async {
  final result = await databases.listDocuments(
    databaseId: DATABASE,
    collectionId: TODO_COLLECTION,
  );
  return result.documents;
}

Future<void> ensureLoggedIn(String email, String password) async {
  try {
    await account.get();
    // Nếu thành công => đang có session => không cần login lại
  } on AppwriteException catch (e) {
    if (e.code == 401) {
      // 401 = Unauthorized => chưa login => cần login
      await login(email, password);
    } else {
      rethrow; // các lỗi khác ném ra
    }
  }
}

Future<Document> create(TodoModel model) async {
  await ensureLoggedIn("hanhtrinhcuathangnam@gmail.com", "123456789");

  final response = await databases.createDocument(
    databaseId: DATABASE,
    collectionId: TODO_COLLECTION,
    documentId: ID.unique(),
    data: {
      'title': model.title,
      'description': model.description,
      'dueDate': model.dueDate.toIso8601String(),
      'color': model.color,
      'isCompleted': model.isCompleted,
      'isNotified': model.isNotified
    },
  );
  return response;
}

Future<Document> update(TodoModel model) async {
  await ensureLoggedIn("hanhtrinhcuathangnam@gmail.com", "123456789");

  final response = await databases.updateDocument(
    databaseId: DATABASE,
    collectionId: TODO_COLLECTION,
    documentId: model.id,
    data: {
      'title': model.title,
      'description': model.description,
      'dueDate': model.dueDate.toIso8601String(),
      'color': model.color,
      'isCompleted': model.isCompleted,
      'isNotified': model.isNotified
    },
  );
  return response;
}

Future<void> delete(String documentId) async {
  await databases.deleteDocument(
    databaseId: DATABASE,
    collectionId: TODO_COLLECTION,
    documentId: documentId,
  );
}
