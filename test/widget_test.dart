import 'package:flutter_test/flutter_test.dart';
import 'package:vet_care/features/favorites/presentation/cubit/favorites_state.dart';

void main() {
  test('favorites state starts empty and loading', () {
    const state = FavoritesState();

    expect(state.products, isEmpty);
    expect(state.pendingProductIds, isEmpty);
    expect(state.isLoading, isTrue);
  });
}
