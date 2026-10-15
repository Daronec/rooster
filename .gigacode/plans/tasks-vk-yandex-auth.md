# Список задач: VK ID и Yandex ID авторизация

## Задача 1: Добавить зависимости в pubspec.yaml
**Статус**: ⬜ pending
**Описание**: Добавить пакеты `vkid_flutter_sdk: ^1.0.3` и `yandex_login_sdk: ^1.0.1` в зависимости приложения.

## Задача 2: Настроить Android проект для VK ID и Yandex ID
**Статус**: ⬜ pending
**Описание**: 
- Добавить VK ID Maven репозиторий в `android/build.gradle`
- Добавить manifest placeholders для VK ID и Yandex в `android/app/build.gradle`
- Настроить proguard rules для VK ID
- Использовать FlutterFragmentActivity для Yandex SDK

## Задача 3: Настроить iOS проект для VK ID и Yandex ID
**Статус**: ⬜ pending
**Описание**:
- Обновить `ios/Podfile` до deployment target 12.0
- Добавить URL schemes в `ios/Runner/Info.plist` для VK ID (`vk{APPID}`) и Yandex (`yx{CLIENT_ID}`)
- Добавить LSApplicationQueriesSchemes
- Добавить обработку callback в `ios/Runner/SceneDelegate.swift` для Yandex

## Задача 4: Создать интерфейс IVkIdGateway
**Статус**: ⬜ pending
**Описание**: Создать `lib/features/auth/domain/gateways/i_vk_id_gateway.dart` с контрактом для VK ID авторизации.

## Задача 5: Создать интерфейс IYandexIdGateway
**Статус**: ⬜ pending
**Описание**: Создать `lib/features/auth/domain/gateways/i_yandex_id_gateway.dart` с контрактом для Yandex ID авторизации.

## Задача 6: Обновить AuthBackendStrategy
**Статус**: ⬜ pending
**Описание**: Добавить значения `vkId` и `yandexId` в enum `AuthBackendStrategy`, обновить функцию `resolveAuthBackendStrategy`.

## Задача 7: Реализовать VkIdAuthGatewayImpl
**Статус**: ⬜ pending
**Описание**: Создать `lib/features/auth/data/vk_id_auth_gateway_impl.dart` с реализацией VK ID OAuth флоу, сохранением токенов в secure storage и эмитом пользователя в authStateChanges.

## Задача 8: Реализовать YandexIdAuthGatewayImpl
**Статус**: ⬜ pending
**Описание**: Создать `lib/features/auth/data/yandex_id_auth_gateway_impl.dart` с реализацией Yandex ID OAuth флоу, сохранением токенов в secure storage и эмитом пользователя в authStateChanges.

## Задача 9: Обновить AuthBackendAssemblyResult и assembleAuthBackend
**Статус**: ⬜ pending
**Описание**: Обновить `lib/features/auth/di/auth_backend_assembler.dart` — заменить Sber ID на VK ID и Yandex ID gateways, убрать CloudRuAuthService и CloudRuClient.

## Задача 10: Обновить IAppScope и AppScope
**Статус**: ⬜ pending
**Описание**: Заменить `sberIdGateway` на `vkIdGateway` и `yandexIdGateway` в `lib/features/app/di/app_scope.dart`.

## Задача 11: Обновить AppScopeRegister
**Статус**: ⬜ pending
**Описание**: Обновить `lib/features/app/di/app_scope_register.dart` — убрать зависимости от cloud.ru, передать новые gateways в AppScope.

## Задача 12: Создать кнопку VK ID Sign In
**Статус**: ⬜ pending
**Описание**: Создать `lib/features/auth/presentation/screens/auth/widgets/vk_id_sign_in_button.dart` с кнопкой входа через VK ID.

## Задача 13: Создать кнопку Yandex ID Sign In
**Статус**: ⬜ pending
**Описание**: Создать `lib/features/auth/presentation/screens/auth/widgets/yandex_id_sign_in_button.dart` с кнопкой входа через Yandex ID.

## Задача 14: Обновить мобильный UI экрана входа
**Статус**: ⬜ pending
**Описание**: Обновить `lib/features/auth/presentation/screens/auth/widgets/mobile/auth_mobile_content.dart` — заменить кнопку Sber ID на VK ID и Yandex ID.

## Задача 15: Обновить десктопный UI экрана входа
**Статус**: ⬜ pending
**Описание**: Обновить `lib/features/auth/presentation/screens/auth/widgets/desktop/auth_desktop_content.dart` — заменить кнопку Sber ID на VK ID и Yandex ID.

## Задача 16: Обновить AuthScreenModel
**Статус**: ⬜ pending
**Описание**: Обновить `lib/features/auth/presentation/screens/auth/auth_model.dart` — убрать зависимость от Sber ID, обновить строки перевода.

## Задача 17: Добавить строки локализации для VK ID и Yandex ID
**Статус**: ⬜ pending
**Описание**: Добавить новые ключи в `assets/flutter_i18n/en.json` и `assets/flutter_i18n/ru.json` для VK ID и Yandex ID.

## Задача 18: Удалить файлы Sber ID
**Статус**: ⬜ pending
**Описание**: Удалить файлы:
- `lib/features/auth/data/sber_id_auth_gateway_impl.dart`
- `lib/features/auth/domain/gateways/i_sber_id_gateway.dart`
- `lib/features/auth/domain/entities/sber_id_user_entity.dart`
- `lib/features/auth/presentation/screens/auth/widgets/sber_id_sign_in_button.dart`
- `lib/features/profile/data/noop_sber_id_gateway_impl.dart`

## Задача 19: Удалить зависимости от CloudRuAuthService и CloudRuClient
**Статус**: ⬜ pending
**Описание**: Удалить или оставить (если используются где-то ещё) файлы cloud.ru auth:
- `lib/features/cloud_ru/auth/cloud_ru_auth_service.dart`
- `lib/features/cloud_ru/api/cloud_ru_client.dart`
- `lib/features/cloud_ru/sync/cloud_ru_sync_executor.dart`
- `lib/features/cloud_ru/sync/cloud_ru_sync_remote_executor.dart`

## Задача 20: Обновить профиль пользователя
**Статус**: ⬜ pending
**Описание**: Проверить и обновить `lib/features/profile/presentation/screens/profile/profile_model.dart` — убрать зависимости от Sber ID.

## Задача 21: Проверить и обновить тесты
**Статус**: ⬜ pending
**Описание**: Найти и обновить/удалить тесты, связанные с Sber ID. Проверить, что новые компоненты покрыты тестами.

## Задача 22: Проверить сборку и протестировать
**Статус**: ⬜ pending
**Описание**: 
- Запустить `flutter pub get`
- Проверить сборку Android: `flutter build apk --debug`
- Проверить сборку iOS: `flutter build ios --debug`
- Протестировать флоу входа через VK ID
- Протестировать флоу входа через Yandex ID
- Проверить восстановление сессии
