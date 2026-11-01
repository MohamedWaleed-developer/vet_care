import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';
import '../widgets/notification_section_title.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (_) => sl<NotificationsCubit>()..startListening(),
        child: const _NotificationsView(),
      ),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'الإشعارات',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        leadingWidth: 150,
        leading: TextButton(
          onPressed: () {
            context
                .read<NotificationsCubit>()
                .markAllAsRead();
          },
          child: const Text(
            'تحديد الكل كمقروء',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3B9B7E),
            ),
          ),
        ),
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.status == NotificationsStatus.loading ||
              state.status == NotificationsStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3B9B7E),
              ),
            );
          }

          if (state.status == NotificationsStatus.failure) {
            return Center(
              child: Text(
                state.errorMessage ?? 'حدث خطأ أثناء تحميل الإشعارات',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (state.notifications.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد إشعارات حالياً',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(
              top: 8,
            ),
            children: [
              if (state.todayNotifications.isNotEmpty) ...[
                const NotificationSectionTitle(
                  title: 'اليوم',
                ),
                ...state.todayNotifications.map(
                      (notification) {
                    return NotificationTile(
                      notification: notification,
                      onTap: () {
                        context
                            .read<NotificationsCubit>()
                            .markAsRead(notification.id);
                      },
                    );
                  },
                ),
              ],
              if (state.earlierNotifications.isNotEmpty) ...[
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                ),
                const NotificationSectionTitle(
                  title: 'سابقاً',
                ),
                ...state.earlierNotifications.map(
                      (notification) {
                    return NotificationTile(
                      notification: notification,
                      onTap: () {
                        context
                            .read<NotificationsCubit>()
                            .markAsRead(notification.id);
                      },
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}