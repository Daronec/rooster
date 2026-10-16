---
name: rooster-auth-debug
description: Диагностика входа и сессий Rooster — OAuth, Appwrite при его подключении, VK ID и Yandex ID, callback-ссылки, отмена входа, выход и восстановление сессии. Используй для сбоев авторизации и связанных переходов.
---

# Диагностика авторизации Rooster

Пути относительны корня репозитория. Начни с активной реализации, а не с
названия backend в старом справочнике. Срез ниже проверен 2026-10-07.

## Определи активный backend

Прочитай `lib/features/auth/domain/auth_backend_strategy.dart`,
`lib/features/auth/di/auth_backend_assembler.dart` и место вызова сборки
в `lib/features/app/di/app_scope_register.dart`.
Сейчас создаются VK ID и Yandex ID gateway, а основным `IAuthGateway`
назначается VK ID. Зависимость `appwrite` в pubspec и комментарии про
Sber ID не доказывают наличие работающего Appwrite/Sber-потока.
Не подключай другой backend в рамках диагностики без такой задачи.

Если пользователь расследует Appwrite, найди регистрацию реального Client,
Account и gateway. При отсутствии регистрации сообщи, что этот путь не
подключён. При наличии проследи создание/восстановление серверной сессии,
настройку провайдера, endpoint/project и callback по используемой версии SDK.

## Карта проверки

| Участок | Файлы |
| --- | --- |
| Контракты и пользователь | `lib/features/auth/domain/gateways/i_auth_gateway.dart`, `lib/features/auth/domain/entities/app_auth_user_entity.dart` |
| SDK и secure storage | `lib/features/auth/data/vk_id_auth_gateway_impl.dart`, `lib/features/auth/data/yandex_id_auth_gateway_impl.dart` |
| UI и реакция на вход | `lib/features/auth/presentation/screens/auth/auth_wm.dart`, `lib/features/auth/presentation/screens/auth/auth_model.dart` |
| Начальный переход | `lib/features/auth/presentation/root_auth_gate/root_auth_gate_wm.dart`, `lib/features/navigation/auth_guard.dart` |
| Обычные ссылки задач | `lib/integration/deep_links/deep_links_coordinator.dart`, `lib/integration/deep_links/deep_link_route_parser.dart` |
| Android callback | `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle.kts` |
| iOS callback | `ios/Runner/Info.plist` |

## Локализуй сбой

1. Зафиксируй платформу, cold/warm start, провайдера, действие пользователя
   и последнюю успешную фазу: запуск SDK → callback → данные пользователя →
   запись сессии → событие auth → навигация. Собери ошибку и stack trace;
   не выводи токены, authorization code или полные callback URL с секретами.
2. Сверь scheme/host, client id, manifest placeholders и URL Types с реально
   используемым SDK. Не принимай заглушки вида `{APPID}` за настройку.
   Task-ссылки `rooster://task/...` обрабатывает отдельный parser; это не
   доказательство обработки OAuth callback. Проверь cold и warm callback,
   а также повторную доставку ссылки без повторного завершения входа.
3. Для Yandex отдельно проверь, какой stream слушает UI: успешный вход в
   Yandex gateway сейчас не равнозначен событию основного VK `IAuthGateway`.
   Проследи источник currentUser, profile и навигационного решения.
4. Отделяй отмену от ошибки провайдера. VK и Yandex gateway пробрасывают
   исключения отмены, а текущий WM ловит общий `Exception`. Проверь возврат
   UI в рабочее состояние, возможность повторного входа и отсутствие
   незавершённого Completer/повторного перехода.
5. Проверь восстановление после полного завершения процесса. Сейчас gateway
   запускают асинхронный restore из конструктора и восстанавливают профиль
   по сохранённому user id. Такой профиль не доказывает действительность
   access token или серверной сессии. Проверь гонку restore с signOut и
   повторным входом, частично сохранённые данные и ошибку secure storage.
6. При выходе проверь очистку данных нужного провайдера, currentUser,
   authStateChanges и последующий cold start. Успешное завершение метода
   не гарантирует успех вложенных операций, если gateway поглощает ошибки.

Основной UI сейчас открывается без обязательного входа; стартовый gate
направляет в список задач. Не вводи принудительный login как побочный фикс.

## Проверка исправления

Для затронутого провайдера проверь success, cancel, ошибку сети/SDK,
некорректную или истёкшую сессию, повторный tap, signOut и cold start.
Fake gateway/secure storage проверяют управление состоянием, но не доказывают
корректность нативных callback: их проверяй на целевой платформе.
Если устройства, backend или доступа к провайдеру нет, явно отметь эту часть
как непроверенную. Выполни подходящие команды из
`../rooster-validation/SKILL.md` и укажи фазу, причину и доказательство исправления.
