import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:midterm/backend/controllers/AuthController.dart';
import 'package:midterm/model/TodoModel.dart';
import '../appwrite_config.dart';

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
