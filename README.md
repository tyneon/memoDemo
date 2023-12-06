# memo

Demo-приложение для создания текстовых заметок с опциональными прикреплёнными датой, временем, списком времён напоминалок, местоположением.

Создано для курса по Flutter в [Клубе Творчества Программистов ПетрГУ](https://acm.petrsu.ru/site/).

## Конфигурация проекта для API/backend

### OpenCage geocoding API

Геокодирование через бесплатное API: опционально, можно удалить его использование из проекта.

Создайте аккаунт на сайте [OpenCage](https://opencagedata.com), выберите план "free while testing".

Ваш API ключ можно найти на странице [Dashboard/Geocoding API](https://opencagedata.com/dashboard#geocoding).

Создайте файл `/lib/location_api_key.dart` со следующим содержимым:

```dart
const locationApiKey = "<ваш API ключ>";
```

### Firestore

Установите и настройте [Firebase CLI](https://firebase.google.com/docs/cli),
войдите в свой Google аккаунт через

```shell
firebase login
```

Из корня проекта запустите команду

```shell
flutterfire configure
```

Подключите Firebase проект из вашего аккаунта.