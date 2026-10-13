import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/cart_item_model.dart';
import '../../data/repositories/cart_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _repository;
  StreamSubscription<List<CartItemModel>>? _itemsSubscription;

  CartCubit(this._repository) : super(const CartState());

  void watchItems() {
    _itemsSubscription?.cancel();
    emit(state.copyWith(isLoading: true, clearError: true));
    _itemsSubscription = _repository.watchItems().listen(
      (items) => emit(state.copyWith(
        items: items,
        isLoading: false,
        clearError: true,
      )),
      onError: (Object error) => emit(state.copyWith(
        isLoading: false,
        errorMessage: error is StateError
            ? 'سجّل الدخول لعرض سلتك.'
            : 'تعذر تحميل السلة. تحقق من اتصالك وحاول مرة أخرى.',
      )),
    );
  }

  Future<bool> changeQuantity(CartItemModel item, int quantity) async {
    _setPending(item.id, true);
    try {
      await _repository.updateQuantity(item.id, quantity);
      return true;
    } catch (_) {
      _setFailure('تعذر تحديث كمية المنتج. حاول مرة أخرى.');
      return false;
    } finally {
      _setPending(item.id, false);
    }
  }

  Future<bool> removeItem(String itemId) async {
    _setPending(itemId, true);
    try {
      await _repository.removeItem(itemId);
      return true;
    } catch (_) {
      _setFailure('تعذر حذف المنتج من السلة. حاول مرة أخرى.');
      return false;
    } finally {
      _setPending(itemId, false);
    }
  }

  Future<bool> clearItems() async {
    emit(state.copyWith(isClearing: true, clearError: true));
    try {
      await _repository.clearItems();
      return true;
    } catch (_) {
      _setFailure('تعذر إفراغ السلة. حاول مرة أخرى.');
      return false;
    } finally {
      emit(state.copyWith(isClearing: false));
    }
  }

  void _setPending(String itemId, bool pending) {
    final pendingIds = Set<String>.from(state.pendingItemIds);
    if (pending) {
      pendingIds.add(itemId);
    } else {
      pendingIds.remove(itemId);
    }
    emit(state.copyWith(pendingItemIds: pendingIds));
  }

  void _setFailure(String message) {
    emit(state.copyWith(errorMessage: message));
  }

  @override
  Future<void> close() async {
    await _itemsSubscription?.cancel();
    return super.close();
  }
}
