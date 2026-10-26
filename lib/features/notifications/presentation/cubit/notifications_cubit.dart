import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/notification_model.dart';
import '../../data/repositories/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;

  StreamSubscription<List<NotificationModel>>? _notificationsSubscription;

  NotificationsCubit(this._repository)
      : super(const NotificationsState());

  void startListening() {
    emit(
      state.copyWith(
        status: NotificationsStatus.loading,
      ),
    );

    _notificationsSubscription?.cancel();

    _notificationsSubscription = _repository
        .watchNotifications()
        .listen(
          (notifications) {
        emit(
          state.copyWith(
            status: NotificationsStatus.success,
            notifications: notifications,
          ),
        );
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: NotificationsStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
    } catch (error) {
      emit(
        state.copyWith(
          status: NotificationsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
    } catch (error) {
      emit(
        state.copyWith(
          status: NotificationsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _notificationsSubscription?.cancel();
    return super.close();
  }
}