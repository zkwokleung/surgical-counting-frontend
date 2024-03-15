import 'package:http/http.dart' as http;
import 'package:surgical_counting/src/constants/backend.dart';

Future<bool> getServerStatus() async {
  final response = await http.get(Uri.parse(serverStatus));
  return response.statusCode == 200;
}
