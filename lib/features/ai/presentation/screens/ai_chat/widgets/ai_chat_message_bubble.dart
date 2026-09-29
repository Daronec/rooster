import 'package:flutter/material.dart';
import 'package:rooster/features/ai/presentation/screens/ai_chat/ai_chat_model.dart';

/// Виджет пузырька сообщения в AI-чате.
///
/// Отображает сообщение пользователя или ассистента с соответствующим стилем.
class AiChatMessageBubble extends StatelessWidget {
  /// Создаёт виджет пузырька.
  const AiChatMessageBubble(this.message, {super.key});

  /// Сообщение для отображения.
  final AiChatMessageEntity message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUser
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
