import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

Future<bool> checkNetworkConnectivity() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    return false; // Không có loại kết nối nào
  }

  // Kiểm tra thật sự có thể truy cập internet không
  try {
    final response = await http.get(Uri.parse('https://www.google.com')).timeout(Duration(seconds: 3));
    return response.statusCode == 200;
  } catch (_) {
    return false; // Có kết nối nhưng không truy cập được internet
  }
}