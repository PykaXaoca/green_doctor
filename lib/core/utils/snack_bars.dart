import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Единый способ показывать SnackBar в приложении.
///
/// Зачем свой хелпер:
///  * фиксированная длительность 3 секунды — сообщения не висят
///    на экране;
///  * floating-поведение — не перекрывает нижнюю навигацию;
///  * кнопка действия использует `GoRouter`, захваченный в момент
///    показа, а не `context` экрана. Это решает проблему «нажал
///    Открыть — ничего не произошло»: context мог размонтироваться
///    раньше, чем пользователь нажмёт.
void showAppSnackBar(
  BuildContext context,
  String message, {
  String? actionLabel,
  String? actionRoute,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 3),
}) {
  final messenger = ScaffoldMessenger.of(context);

  // Захватываем роутер ДО показа. Он глобальный и остаётся
  // валидным, даже если экран будет закрыт.
  GoRouter? router;
  if (actionRoute != null) {
    router = GoRouter.of(context);
  }

  // Убираем предыдущее сообщение, чтобы не накапливались.
  messenger.hideCurrentSnackBar();

  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      action: (actionLabel != null && (router != null || onAction != null))
          ? SnackBarAction(
              label: actionLabel,
              onPressed: () {
                if (router != null && actionRoute != null) {
                  router.push(actionRoute);
                } else if (onAction != null) {
                  onAction();
                }
              },
            )
          : null,
    ),
  );
}

/// Вариант для ошибок — красный фон, чтобы сразу бросалось в глаза.
void showErrorSnackBar(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red.shade700,
    ),
  );
}
