import 'dart:convert';

abstract class JsonModel {
  final _prettyEncoder = JsonEncoder.withIndent("  ");

  /// Note: the way dart:convert and json_serializable works, toJson needs to
  /// return a map. Use toJsonString to get the object in a json-structured
  /// string.
  Map<String, dynamic> toJson() => toMap();
  Map<String, dynamic> toMap();
  String toJsonString() => jsonEncode(toMap());

  @override
  String toString() => _prettyEncoder.convert(toMap());
}
