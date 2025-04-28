import 'package:appwrite/appwrite.dart';

final client = Client()
    .setEndpoint('https://fra.cloud.appwrite.io/v1')
    .setProject('6808d76b0017fb762a1a');

final account = Account(client);
final databases = Databases(client);

const DATABASE = '6808de5f0009e65839f9';
const TODO_COLLECTION = '6808df910006ad685af3';
