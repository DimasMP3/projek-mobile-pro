import '../models/fun_item_model.dart';
import '../sources/remote/fun_api.dart';

class FunRepository {
  final _api = FunApi();

  Future<List<FunItem>> fetchFunItems() async {
    try {
      final items = await _api.fetchFunItems();
      return items;
    } catch (_) {
      return <FunItem>[];
    }
  }
}

