# Модуль навигации

Здесь живут **граф AutoRoute** (`app_router.dart`, сгенерированный `app_router.gr.dart`), мобильный и десктопный роутеры, гварды и обвязка десктопной оболочки.

**Строковые сегменты путей** вынесены в `lib/app_routing/app_route_paths.dart` (`AppRoutePaths`), чтобы не смешивать общий контракт URL с импортами экранов.

Подробнее о связности с фичами и эволюции структуры: [docs/NAVIGATION_AND_FEATURES.md](../../docs/NAVIGATION_AND_FEATURES.md).
