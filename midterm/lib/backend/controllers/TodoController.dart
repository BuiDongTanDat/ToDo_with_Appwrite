import 'package:appwrite/appwrite.dart';
import 'package:midterm/model/TodoModel.dart';
import '../appwrite_config.dart';

Future<Map<String, Object?>> getTodos() async {
  try {
    final result = await databases.listDocuments(
      databaseId: DATABASE,
      collectionId: TODO_COLLECTION,
    );

    return {
      'code': 200,
      'response': result.documents,
    };
  } catch (e) {
    throw Exception("Unexpected error in getTodos(): $e");
  }
}

Future<Map<String, Object?>> createOrUpdate(TodoModel model, int action) async {
  // action = 0 = add
  // action = 1 = update
  try {
    final response = await databases.createDocument(
      databaseId: DATABASE,
      collectionId: TODO_COLLECTION,
      documentId: action == 0 ? ID.unique() : model.id,
      data: {
        'title': model.title,
        'description': model.description,
        'dueDate': model.dueDate.toIso8601String(),
        'color': model.color,
        'isCompleted': model.isCompleted,
        'isNotified': model.isNotified
      },
    );

    return {
      'code': 200,
      'response': response,
    };
  } on AppwriteException catch (e) {
    return {'code': e.code, 'response': e.message};
  } catch (e) {
    throw Exception("Unexpected error in createOrUpdate(): $e");
  }
}

Future<void> delete(String documentId) async {
  await databases.deleteDocument(
    databaseId: DATABASE,
    collectionId: TODO_COLLECTION,
    documentId: documentId,
  );
}
