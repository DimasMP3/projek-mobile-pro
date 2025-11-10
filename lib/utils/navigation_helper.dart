import 'package:flutter/material.dart';

Future<T?> push<T>(BuildContext ctx, String route, {Object? args}) {
  return Navigator.of(ctx).pushNamed<T>(route, arguments: args);
}

void replace(BuildContext ctx, String route, {Object? args}) {
  Navigator.of(ctx).pushReplacementNamed(route, arguments: args);
}
