import 'package:flutter/material.dart';
import 'package:rooster/features/ai/presentation/screens/ai_chat/ai_chat_model.dart';
import 'package:rooster/features/ai/presentation/screens/ai_chat/ai_chat_wm.dart';
import 'package:rooster/features/ai/presentation/strings/ai_chat_strings.dart';

/// Виджет поля ввода сообщения.
class AiChatInputField extends StatelessWidget {
  const AiChatInputField({required this.wm, super.key});

  final AiChatScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: wm.controller,
                decoration: InputDecoration(
                  hintText: AiChatStrings.inputHint(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                enabled: wm.state != AiChatState.sending,
                onSubmitted: (_) => wm.sendMessage(context),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: IconButton(
                icon: wm.state == AiChatState.sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
                onPressed: wm.state != AiChatState.sending
                    ? () => wm.sendMessage(context)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
