import 'package:flutter_test/flutter_test.dart';

import 'package:http_serializer/http_serializer.dart';
import 'package:http/http.dart';

void main() {
  test('test get post', () async {
    final serializer = HttpSerializer(
      client: Client(),
      baseUrl: "https://jsonplaceholder.typicode.com/",
    );
    print("post: ${await serializer.get('posts', (map) => Post.fromMap(map), 2)}");
  });
}

class Post extends JsonModel {
  final int id;
  final String title;

  Post({this.id, this.title});

  factory Post.fromMap(final Map<String, dynamic> map) => Post(
    id: map['id'],
    title: map['title'],
  );

  @override
  Map<String, dynamic> toMap() => { "title": title, "id": id };
}
