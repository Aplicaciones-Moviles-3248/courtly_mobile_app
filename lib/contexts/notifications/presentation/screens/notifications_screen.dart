import 'package:flutter/material.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../../../shared/presentation/widgets/courtly_bottom_navigation_bar.dart';
import '../../application/use_cases/get_my_notifications_use_case.dart';
import '../../application/use_cases/get_unread_notifications_count_use_case.dart';
import '../../application/use_cases/mark_notification_as_read_use_case.dart';
import '../../application/use_cases/delete_notification_use_case.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../infrastructure/datasources/notification_remote_data_source.dart';
import '../../infrastructure/repositories/notification_repository_impl.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_badge.dart';

class NotificationsScreen extends StatefulWidget {

  final NotificationRepository? repository;

  const NotificationsScreen({super.key, this.repository});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final GetMyNotificationsUseCase getMyNotificationsUseCase;
  late final GetUnreadNotificationsCountUseCase getUnreadCountUseCase;
  late final MarkNotificationAsReadUseCase markAsReadUseCase;
  late final DeleteNotificationUseCase deleteNotificationUseCase;

  List<NotificationEntity> notifications = [];
  bool isLoading = true;
  String? errorMessage;
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _buildDependencies();
    _load();
  }

  void _buildDependencies() {
    final repo = widget.repository ?? _buildRemoteRepository();
    getMyNotificationsUseCase = GetMyNotificationsUseCase(repo);
    getUnreadCountUseCase = GetUnreadNotificationsCountUseCase(repo);
    markAsReadUseCase = MarkNotificationAsReadUseCase(repo);
    deleteNotificationUseCase = DeleteNotificationUseCase(repo);
  }

  NotificationRepository _buildRemoteRepository() {
    final localStorage = LocalStorageService();
    final apiClient = ApiClient(localStorage);
    final remoteDataSource = NotificationRemoteDataSource(apiClient);
    return NotificationRepositoryImpl(remoteDataSource);
  }

  Future<void> _load() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await getMyNotificationsUseCase.execute();
      if (!mounted) return;
      setState(() {
        notifications = results;
        isLoading = false;
      });
      await _loadUnreadCount(); // actualiza badge/contador
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage =
        'No se pudieron cargar las notificaciones.\nVerifique su conexión.';
      });
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final cnt = await getUnreadCountUseCase.execute();
      if (!mounted) return;
      setState(() {
        unreadCount = cnt.unreadCount;
      });
    } catch (_) {
    }
  }

  Future<void> _markAsRead(NotificationEntity item) async {
    if (item.isRead) return;
    try {
      await markAsReadUseCase.execute(item.id);
    } catch (_) {
    } finally {
      if (!mounted) return;
      setState(() {
        notifications = notifications
            .map((n) => n.id == item.id ? n.copyWith(isRead: true) : n)
            .toList();
        if (unreadCount > 0) unreadCount = unreadCount - 1;
      });
    }
  }

  Future<void> _deleteNotification(NotificationEntity item) async {
    final removedIndex =
    notifications.indexWhere((n) => n.id == item.id);
    setState(() {
      notifications = notifications.where((n) => n.id != item.id).toList();
      if (!item.isRead && unreadCount > 0) unreadCount = unreadCount - 1;
    });

    try {
      await deleteNotificationUseCase.execute(item.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notificación eliminada')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        final list = notifications.toList();
        list.insert(removedIndex >= 0 ? removedIndex : list.length, item);
        notifications = list;
        if (!item.isRead) unreadCount = unreadCount + 1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar la notificación')),
      );
    }
  }

  Future<void> _onTapNotification(NotificationEntity item) async {
    await _markAsRead(item);

    final relatedType = item.relatedEntityType?.toLowerCase();
    final relatedId = item.relatedEntityId;
    if (relatedType == null || relatedId == null) {
      return;
    }

    if (relatedType == 'court' || relatedType == 'cancha') {
      Navigator.pushNamed(context, AppRoutes.courtDetail,
          arguments: relatedId);
      return;
    }

    if (relatedType == 'booking' || relatedType == 'reserva') {
      Navigator.pushNamed(context, AppRoutes.myBookings);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const CourtlyBottomNavigationBar(currentIndex: 2),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: AppColors.textPrimary),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Volver',
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'NOTIFICACIONES',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                      NotificationBadge(
                        unreadCount: unreadCount,
                        onPressed: () async {
                          await _loadUnreadCount();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tus avisos y actualizaciones',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Desliza hacia la izquierda para eliminar una notificación.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: _buildBody(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    if (notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 40),
            Center(
              child: Text(
                'No tienes notificaciones por ahora.',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 110),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];
          return NotificationCard(
            key: ValueKey(n.id),
            notification: n,
            onTap: () => _onTapNotification(n),
            onDelete: () => _deleteNotification(n),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}