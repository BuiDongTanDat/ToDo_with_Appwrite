import 'package:appwrite/appwrite.dart';

final client = Client()
    .setEndpoint('http://10.0.2.2/v1')
    .setProject('680a19460008faafadca')
    .setSelfSigned(status: true);

final account = Account(client);
final databases = Databases(client);

const DATABASE = '680a19f5002a4902d133';
const TODO_COLLECTION = '680a68650019c22cc811';
