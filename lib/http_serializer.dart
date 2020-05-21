library http_serializer;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_serializer/src/json_model.dart';

export 'package:http_serializer/src/json_model.dart';

typedef S InstanceCreator<S>(Map<String, dynamic> map);

enum ContentType { json, bytes }

class HttpSerializer {
  final String baseUrl;
  final http.Client _client;

  HttpSerializer({@required this.baseUrl, @required final http.Client client})
    : _client = client;

  Future<T> get<T>(
      final String endpoint, final InstanceCreator<T> create, [final int id])
      async {
    final idString = (id == null) ? "" : "/$id";
    final map = await _get("$baseUrl$endpoint$idString");
    return create(map);
  }

  Future<K> post<T extends JsonModel, K>(final String endpoint, T model,
      InstanceCreator<K> create,
      {Map<String, String> headers, ContentType contentType}) async {
    final response = await _client.post(
      "$baseUrl$endpoint",
      headers: headers,
      body: (contentType == ContentType.json) ? model.toJsonString()
                                              : model.toMap()
    );
    _throwExceptionOnInvalid(response);
    final responseObject = create((await compute(jsonDecode, response.body))
      as Map<String, dynamic>);
    return responseObject;
  }

  Future<List<T>> list<T>(
      final String endpoint, final InstanceCreator<T> create) async {
    final collection = await _get("$baseUrl$endpoint");
    return collection.map<T>((eachMap) => create(eachMap)).toList();
  }

  /// get response from endpoints in the format
  /// /[endpoint1]/[id1]/[endpoint2]
  Future<List<T>> relationalList<T>(
      final String endpoint1, final int id1, final String endpoint2,
      final InstanceCreator<T> create) async {
    final collection = await _get("$baseUrl$endpoint1/$id1/$endpoint2");
    return collection.map<T>((eachMap) => create(eachMap)).toList();
  }

  Future<dynamic> _get(String url) async {
    final response = await _client.get(url);

    _throwExceptionOnInvalid(response);

    final collection = await compute(jsonDecode, response.body);
    return collection;
  }

  void _throwExceptionOnInvalid(final http.Response response) {
    if (!(response.statusCode > 199 && response.statusCode < 300)) {
      final http.Request req = response.request;
      throw Exception("Error ${response.statusCode} ${response.request}\n"
        "request body: ${req.body}\nresponse body: ${response.body}");
    }
  }
}
