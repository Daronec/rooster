import 'package:flutter/foundation.dart';
import 'package:huawei_analytics/huawei_analytics.dart';
import 'package:rooster/core/analytics/i_app_analytics_gateway.dart';

/// [IAppAnalyticsGateway] через HMS Analytics Kit.
final class HuaweiAppAnalyticsGatewayImpl implements IAppAnalyticsGateway {
  /// Создаёт шлюз (ленивая инициализация [HMSAnalytics]).
  HuaweiAppAnalyticsGatewayImpl({String routePolicy = 'RU'}) : _routePolicy = routePolicy;

  final String _routePolicy;
  HMSAnalytics? _hms;

  Future<HMSAnalytics> _client() async {
    final existing = _hms;
    if (existing != null) {
      return existing;
    }
    final created = await HMSAnalytics.getInstance(routePolicy: _routePolicy);
    await created.setAnalyticsEnabled(true);
    if (kDebugMode) {
      await created.enableLog();
    }
    _hms = created;
    return created;
  }

  @override
  Future<void> logAppOpen() async {
    final client = await _client();
    await client.onEvent('app_open', <String, dynamic>{});
  }

  @override
  Future<void> logCreateTask() async {
    final client = await _client();
    await client.onEvent('create_task', <String, dynamic>{});
  }

  @override
  Future<void> logCompleteTask() async {
    final client = await _client();
    await client.onEvent('complete_task', <String, dynamic>{});
  }

  @override
  Future<void> logDeleteTask() async {
    final client = await _client();
    await client.onEvent('delete_task', <String, dynamic>{});
  }
}
