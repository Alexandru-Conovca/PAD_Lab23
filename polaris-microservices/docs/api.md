# Спецификация API микросервисов Polaris

Все микросервисы доступны через единую точку входа API Gateway: `http://localhost:8080`.
Каждый микросервис также предоставляет интерактивную документацию Swagger UI по адресу `/docs` (например, `http://localhost:8001/docs`).

---

## 1. Auth Service (`:8001` / `/api/auth`)

| Метод | Путь | Описание | Защита |
|---|---|---|---|
| `POST` | `/api/auth/register` | Регистрация нового пользователя | Нет |
| `POST` | `/api/auth/login` | Вход по логину и паролю, выдача JWT и refresh token | Нет |
| `POST` | `/api/auth/refresh` | Ротация refresh token и выдача нового access token | Нет |
| `GET` | `/api/auth/me` | Получение профиля текущего пользователя | Bearer JWT |
| `GET` | `/health` | Проверка жизнеспособности сервиса | Нет |
| `GET` | `/ready` | Проверка готовности (БД) | Нет |

---

## 2. Catalog Service (`:8002` / `/api/catalog`)

| Метод | Путь | Описание | Защита |
|---|---|---|---|
| `GET` | `/api/catalog/objects` | Список объектов (фильтры: `type`, `constellation`, `visible_only`, пагинация) | Нет |
| `GET` | `/api/catalog/objects/{id}` | Полная информация об объекте | Нет |
| `GET` | `/api/catalog/objects/search?q={query}` | Полнотекстовый поиск по каталогу | Нет |
| `GET` | `/api/catalog/categories` | Список астрономических категорий | Нет |
| `GET` | `/api/catalog/favorites` | Список избранных объектов пользователя | Bearer JWT |
| `POST` | `/api/catalog/favorites` | Добавление объекта в избранное пользователя | Bearer JWT |
| `DELETE` | `/api/catalog/favorites/{object_id}` | Удаление объекта из избранного | Bearer JWT |

---

## 3. Equipment Service (`:8003` / `/api/equipment`)

| Метод | Путь | Описание | Защита |
|---|---|---|---|
| `GET` | `/api/equipment` | Список оборудования текущего пользователя | Bearer JWT |
| `POST` | `/api/equipment` | Добавление нового телескопа | Bearer JWT |
| `GET` | `/api/equipment/{id}` | Детальная информация об оборудовании | Bearer JWT |
| `PUT` | `/api/equipment/{id}` | Редактирование характеристик телескопа | Bearer JWT |
| `DELETE` | `/api/equipment/{id}` | Удаление телескопа | Bearer JWT |
| `POST` | `/api/equipment/{id}/set-active` | Назначение телескопа основным | Bearer JWT |

---

## 4. Observation Service (`:8004` / `/api/observations`)

| Метод | Путь | Описание | Защита |
|---|---|---|---|
| `POST` | `/api/observations` | Регистрация наблюдения (202 Accepted, публикация в RabbitMQ) | Bearer JWT |
| `GET` | `/api/observations` | История наблюдений пользователя (фильтры: `status`, `quest_id`) | Bearer JWT |
| `GET` | `/api/observations/{id}` | Карточка наблюдения со статусом верификации | Bearer JWT |
| `PUT` | `/api/observations/{id}` | Редактирование заметок наблюдения | Bearer JWT |
| `DELETE` | `/api/observations/{id}` | Удаление записи наблюдения | Bearer JWT |

---

## 5. Quest Service (`:8005` / `/api/quests`)

| Метод | Путь | Описание | Защита |
|---|---|---|---|
| `GET` | `/api/quests` | Список доступных квестов (фильтр: `difficulty`) | Нет |
| `POST` | `/api/quests/generate` | Генерация квеста на основе правил сложности | Нет |
| `GET` | `/api/quests/my` | Активные и завершенные квесты пользователя | Bearer JWT |
| `POST` | `/api/quests/{id}/start` | Запуск прохождения квеста | Bearer JWT |
| `GET` | `/api/quests/{id}/progress` | Текущий прогресс и чек-лист задач квеста | Bearer JWT |
| `POST` | `/api/quests/{id}/complete` | Завершение квеста | Bearer JWT |

---

## 6. Verification Service (`:8006` / `/api/verification`)

| Метод | Путь | Описание | Защита |
|---|---|---|---|
| `POST` | `/api/verification/verify` | Прямой запуск ручной верификации наблюдения | Нет |
| `GET` | `/api/verification/rules` | Список действующих правил верификации | Нет |
| `GET` | `/api/verification/{id}` | Протокол проверки наблюдения | Нет |

---

## 7. Weather Service (`:8007` / `/api/weather`)

| Метод | Путь | Описание | Защита |
|---|---|---|---|
| `GET` | `/api/weather/current?latitude=..&longitude=..` | Текущая метеорологическая сводка | Нет |
| `GET` | `/api/weather/forecast?latitude=..&longitude=..` | Почасовой прогноз для наблюдений | Нет |
| `GET` | `/api/weather/conditions?latitude=..&longitude=..` | Оценка условий и прозрачности неба | Нет |
