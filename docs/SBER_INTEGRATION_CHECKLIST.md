# Чек-лист интеграции Sber ID (Native SDK + Cloud.ru)

Этот документ содержит пошаговый план реализации авторизации через Sber ID с использованием нативного SDK и серверless-функций на платформе Cloud.ru. Архитектура полностью исключает использование Appwrite, Firebase или Supabase.

---

## 📋 Статус выполнения

- [ ] **1. Настройка Sber ID Developer Portal**
- [ ] **2. Создание Cloud Function (Cloud.ru)**
- [ ] **3. Настройка Android (Native)**
- [ ] **4. Настройка iOS (Native)**
- [ ] **5. Обновление Flutter кода (DI & Logic)**
- [ ] **6. Финальное тестирование**

---

## 1. Настройка Sber ID Developer Portal

**Цель:** Зарегистрировать приложение и получить учетные данные.

- [ ] Зайти в [Sber ID Developer Portal](https://developers.sber.ru/).
- [ ] Создать новое приложение типа "Web" или "Mobile" (в зависимости от требований портала).
- [ ] Получить `Client ID` и `Client Secret`.
- [ ] Настроить **Redirect URI**:
  - Для Android: `rooster-auth://sber-id`
  - Для iOS: `rooster-auth://sber-id`
- [ ] Записать полученные данные в безопасное место.
- [ ] Убедиться, что выбранные `Scope` включают: `openid`, `profile`, `email`.

---

## 2. Создание Cloud Function (Cloud.ru)

**Цель:** Реализовать безопасный обмен `auth_code` на `access_token` и получение данных пользователя.

### 2.1. Подготовка окружения
- [ ] Войти в консоль Cloud.ru (Serverless Functions).
- [ ] Создать новую функцию (Runtime: Node.js 18+ или Python 3.9+).
- [ ] Добавить переменные окружения в настройках функции:
  - `SBER_CLIENT_ID`
  - `SBER_CLIENT_SECRET`
  - `SBER_AUTH_URL` (обычно `https://ngw.login.sberbank.ru/api/v2/oauth`)
  - `SBER_TOKEN_URL` (обычно `https://ngw.login.sberbank.ru/api/v2/oauth/token`)
  - `SBER_USER_INFO_URL` (обычно `https://ngw.login.sberbank.ru/api/v2/userinfo`)

### 2.2. Код функции (Node.js пример)
- [ ] Создать файл `index.js` со следующим содержанием:

```javascript
exports.handler = async function (event, context) {
    const { auth_code } = event.queryStringParameters || JSON.parse(event.body);

    if (!auth_code) {
        return {
            statusCode: 400,
            body: JSON.stringify({ error: 'auth_code is required' })
        };
    }

    const clientId = process.env.SBER_CLIENT_ID;
    const clientSecret = process.env.SBER_CLIENT_SECRET;
    const redirectUri = 'rooster-auth://sber-id';
    const tokenUrl = process.env.SBER_TOKEN_URL;
    const userInfoUrl = process.env.SBER_USER_INFO_URL;

    try {
        // 1. Обмен кода на токен
        const tokenResponse = await fetch(tokenUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams({
                grant_type: 'authorization_code',
                code: auth_code,
                client_id: clientId,
                client_secret: clientSecret,
                redirect_uri: redirectUri
            })
        });

        if (!tokenResponse.ok) {
            throw new Error('Token exchange failed');
        }

        const { access_token } = await tokenResponse.json();

        // 2. Получение данных пользователя
        const userResponse = await fetch(userInfoUrl, {
            headers: { 'Authorization': `Bearer ${access_token}` }
        });

        if (!userResponse.ok) {
            throw new Error('User info fetch failed');
        }

        const userInfo = await userResponse.json();

        // 3. Здесь можно добавить логику создания сессии (JWT) или сохранения в БД Cloud.ru

        return {
            statusCode: 200,
            body: JSON.stringify({
                success: true,
                user: userInfo,
                // token: generatedSessionToken // Если нужна своя сессия
            })
        };

    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({ error: error.message })
        };
    }
};
```

- [ ] Задеплоить функцию.
- [ ] Получить публичный URL функции (например, `https://...cloud.ru/functions/sber-auth`).
- [ ] Добавить этот URL в Flutter проект (в `.env` как `CLOUD_SBER_AUTH_URL`).

---

## 3. Настройка Android (Native)

**Цель:** Подключить нативный SDK и обработать редирект.

### 3.1. Зависимости
- [ ] Открыть `android/app/build.gradle`.
- [ ] В блок `dependencies` добавить:
  ```gradle
  implementation 'ru.sber:id-sdk:2.0.0' // Проверить актуальную версию
  ```
- [ ] Убедиться, что `minSdkVersion` >= 21.

### 3.2. Манифест
- [ ] Открыть `android/app/src/main/AndroidManifest.xml`.
- [ ] Добавить разрешение (если нет):
  ```xml
  <uses-permission android:name="android.permission.INTERNET" />
  ```
- [ ] В тег `<activity>` (основной лаунчер) добавить `intent-filter`:
  ```xml
  <intent-filter android:autoVerify="true">
      <action android:name="android.intent.action.VIEW" />
      <category android:name="android.intent.category.DEFAULT" />
      <category android:name="android.intent.category.BROWSABLE" />
      <data android:scheme="rooster-auth" android:host="sber-id" />
  </intent-filter>
  ```

### 3.3. Kotlin код (MainActivity)
- [ ] Открыть `android/app/src/main/kotlin/.../MainActivity.kt`.
- [ ] Реализовать обработку входящего Intent для получения кода авторизации.
- [ ] Использовать `MethodChannel` для передачи кода во Flutter.

*Пример логики в `onNewIntent`:*
```kotlin
override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    intent.data?.let { uri ->
        if (uri.scheme == "rooster-auth" && uri.host == "sber-id") {
            val code = uri.getQueryParameter("code")
            // Отправить code во Flutter через MethodChannel
            channel.invokeMethod("onSberAuthCode", code)
        }
    }
}
```

---

## 4. Настройка iOS (Native)

**Цель:** Подключить SDK и обработать Universal Links / URL Schemes.

### 4.1. CocoaPods
- [ ] Открыть `ios/Podfile`.
- [ ] Добавить строку: `pod 'SberIDSDK', '~> 2.0'`
- [ ] Выполнить в терминале: `cd ios && pod install`

### 4.2. Info.plist
- [ ] Открыть `ios/Runner/Info.plist`.
- [ ] Добавить `CFBundleURLTypes`:
  ```xml
  <key>CFBundleURLTypes</key>
  <array>
      <dict>
          <key>CFBundleURLSchemes</key>
          <array>
              <string>rooster-auth</string>
          </array>
      </dict>
  </array>
  ```
- [ ] Добавить `LSApplicationQueriesSchemes` (для проверки наличия приложения Сбербанка):
  ```xml
  <key>LSApplicationQueriesSchemes</key>
  <array>
      <string>sberbank</string>
      <string>sberbankonline</string>
  </array>
  ```

### 4.3. AppDelegate
- [ ] Открыть `ios/Runner/AppDelegate.swift`.
- [ ] Переопределить метод `application(_:open:options:)` для перехвата URL.
- [ ] Передать код во Flutter через `FlutterMethodChannel`.

---

## 5. Обновление Flutter кода (DI & Logic)

**Цель:** Связать нативную часть с бизнес-логикой и UI.

- [ ] **Platform Channel:** Создать сервис `SberNativeService` для вызова нативных методов (запуск SDK) и получения кода через Stream/Callback.
- [ ] **Gateway:** Убедиться, что `SberIdAuthGatewayImpl` использует новый сервис для получения кода и отправляет его на Cloud Function URL.
- [ ] **DI Container:**
  - [ ] Зарегистрировать `SberNativeService` в контейнере зависимостей.
  - [ ] Зарегистрировать `SberIdAuthGatewayImpl` как реализацию `ISberIdGateway`.
  - [ ] Внедрить зависимость в `AuthScreenViewModel`.
- [ ] **Environment:** Добавить `CLOUD_SBER_AUTH_URL` в `.env` и `flutter_dotenv`.

---

## 6. Финальное тестирование

- [ ] Запустить приложение на реальном Android устройстве (эмулятор может не поддерживать редиректы в приложении банка).
- [ ] Запустить приложение на реальном iOS устройстве.
- [ ] Проверить сценарий: Нажатие кнопки -> Открытие приложения Сбер -> Успешный вход -> Редирект обратно -> Получение токена от Cloud Function.
- [ ] Проверить обработку ошибок (отмена входа, отсутствие интернета, неверный код).
- [ ] Убедиться, что секреты не утекают в клиентский код (проверить трафик).

---

## Примечания

- **Безопасность:** Никогда не храните `SBER_CLIENT_SECRET` в коде приложения. Только в Cloud Function.
- **Версии SDK:** Всегда проверяйте актуальную версию SDK в документации Сбера.
- **Deep Links:** На некоторых устройствах может потребоваться дополнительная настройка "Открывать по умолчанию" для схемы `rooster-auth`.
