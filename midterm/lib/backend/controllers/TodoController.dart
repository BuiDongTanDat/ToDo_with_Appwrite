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

Future<Document> create(TodoModel model) async {
  await login("test@gmail.com", "12345678");

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
  await login("test@gmail.com", "12345678");

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
