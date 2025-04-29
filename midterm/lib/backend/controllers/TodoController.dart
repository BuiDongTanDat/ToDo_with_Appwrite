import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:midterm/model/TodoModel.dart';
import '../appwrite_config.dart';

Future<Map<String, Object?>> getTodos(String userId) async {
  try {
    final result = await databases.listDocuments(
      databaseId: DATABASE,
      collectionId: TODO_COLLECTION,
      queries: [
        Query.equal('userId', userId), // Lọc theo userId
      ],
    );

    return {
      'code': 200,
      'response': result.documents,
    };
  } on AppwriteException catch (e) {
    print('Error in getTodos: ${e.message} (code: ${e.code})');
    return {
      'code': e.code ?? 400,
      'response': e.message ?? 'Failed to fetch todos',
    };
  } catch (e) {
    print('Unexpected error in getTodos: $e');
    return {
      'code': 500,
      'response': 'Unexpected error: $e',
    };
  }
}

Future<Map<String, Object?>> createOrUpdate(TodoModel model, int action) async {
  // action = 0 -> create
  // action = 1 -> update
  try {
    // Get the current user's ID
    final account = Account(client);
    final user = await account.get();
    final userId = user.$id;

    // Validate that model.userId matches the current user
    if (model.userId != userId) {
      return {
        'code': 403,
        'response': 'Unauthorized: User ID mismatch',
      };
    }

    Document response;
    if (action == 0) {
      response = await databases.createDocument(
        databaseId: DATABASE,
        collectionId: TODO_COLLECTION,
        documentId: ID.unique(),
        data: {
          'title': model.title,
          'description': model.description,
          'dueDate': model.dueDate.toIso8601String(),
          'color': model.color,
          'isCompleted': model.isCompleted,
          'isNotified': model.isNotified,
          'notificationDate': model.notificationDate?.toIso8601String(),
          'userId': userId,
        },
      );
    } else {
      response = await databases.updateDocument(
        databaseId: DATABASE,
        collectionId: TODO_COLLECTION,
        documentId: model.id,
        data: {
          'title': model.title,
          'description': model.description,
          'dueDate': model.dueDate.toIso8601String(),
          'color': model.color,
          'isCompleted': model.isCompleted,
          'isNotified': model.isNotified,
          'notificationDate': model.notificationDate?.toIso8601String(),
          'userId': userId,
        },
      );
    }

    return {
      'code': action == 0 ? 201 : 200,
      'response': response,
    };
  } on AppwriteException catch (e) {
    print('Error in createOrUpdate (action: $action): ${e.message} (code: ${e.code})');
    return {
      'code': e.code ?? 400,
      'response': e.message ?? 'Failed to ${action == 0 ? 'create' : 'update'} todo',
    };
  } catch (e) {
    print('Unexpected error in createOrUpdate (action: $action): $e');
    return {
      'code': 500,
      'response': 'Unexpected error: $e',
    };
  }
}

Future<Map<String, Object?>> delete(String documentId) async {
  try {
    // Get the current user's ID
    final account = Account(client);
    final user = await account.get();
    final userId = user.$id;

    // Fetch the document to verify ownership
    final document = await databases.getDocument(
      databaseId: DATABASE,
      collectionId: TODO_COLLECTION,
      documentId: documentId,
    );

    if (document.data['userId'] != userId) {
      return {
        'code': 403,
        'response': 'Unauthorized: You do not own this todo',
      };
    }

    await databases.deleteDocument(
      databaseId: DATABASE,
      collectionId: TODO_COLLECTION,
      documentId: documentId,
    );

    return {
      'code': 200,
      'response': 'Todo deleted successfully',
    };
  } on AppwriteException catch (e) {
    print('Error in delete: ${e.message} (code: ${e.code})');
    return {
      'code': e.code ?? 400,
      'response': e.message ?? 'Failed to delete todo',
    };
  } catch (e) {
    print('Unexpected error in delete: $e');
    return {
      'code': 500,
      'response': 'Unexpected error: $e',
    };
  }
}