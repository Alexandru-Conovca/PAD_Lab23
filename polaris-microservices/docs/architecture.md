# Архитектурная документация Polaris Microservices

## 1. Концепция и цели системы

**Polaris** — распределенная событийно-ориентированная система для планирования, выполнения и автоматической верификации астрономических наблюдений любителями астрономии.

### Основные сценарии:
1. Регистрация и управление профилем пользователя (`Auth Service`).
2. Настройка телескопов и оборудования (`Equipment Service`).
3. Поиск и фильтрация объектов звездного неба (`Catalog Service`).
4. Мониторинг метеорологических условий и астрономической видимости (`Weather Service`).
5. Прохождение квестов и астрономических заданий (`Quest Service`).
6. Регистрация наблюдений (`Observation Service`).
7. Автоматическая проверка достоверности наблюдений (`Verification Service`).

---

## 2. Архитектура системы

Система построена на принципах **Microservice Architecture** и **Database per Service**:

```
                       +----------------------------------+
                       |   Flutter Client / Frontend UI   |
                       +-----------------+----------------+
                                         | HTTP/REST
                                         v
                       +----------------------------------+
                       |   API Gateway (Traefik Proxy)    |
                       |         Port 8080 / 80           |
                       +-----------------+----------------+
                                         |
     +-----------------+-----------------+-----------------+-----------------+
     |                 |                 |                 |                 |
     v                 v                 v                 v                 v
+----------+     +----------+     +----------+     +----------+     +----------+
|   Auth   |     | Catalog  |     |Equipment |     |Observation|    |  Weather |
| Service  |     | Service  |     | Service  |     | Service  |     | Service  |
|  :8001   |     |  :8002   |     |  :8003   |     |  :8004   |     |  :8007   |
+----+-----+     +----+-----+     +----+-----+     +----+-----+     +----+-----+
     |                |                |                |                |
+----+-----+     +----+-----+     +----+-----+          |           +----+-----+
| auth_db  |     |catalog_db|     |equipment_db         |           |weather_db|
+----------+     +----------+     +----------+          |           +----------+
                                                        |
                                                        v Event: observation.submitted
                                              +-------------------+
                                              | RabbitMQ Broker   |
                                              |  Exchange:        |
                                              |  polaris.events   |
                                              +---+-----------+---+
                                                  |           ^
                                                  |           | Event: observation.verified /
                                                  v           |        observation.rejected
                                          +-------+-----------+-------+
                                          |   Verification Service    |
                                          |          :8006            |
                                          +-------------+-------------+
                                                        |
                                                        | Sync REST calls:
                                                        +---> Catalog Service (RA/Dec)
                                                        +---> Weather Service (Cloud cover)
                                                        |
                                                  +-----+------+
                                                  |verification_db
                                                  +------------+
                                                        |
                                                        v Event: observation.verified
                                              +---------+---------+
                                              |   Quest Service   |
                                              |       :8005       |
                                              +---------+---------+
                                                        |
                                                  +-----+----+
                                                  | quest_db |
                                                  +----------+
```

---

## 3. Взаимодействие между сервисами

### 3.1 Синхронное взаимодействие (REST API)
* **Client / UI → API Gateway → Services**: маршрутизация внешних HTTP-запросов по префиксам путей.
* **Verification Service → Catalog Service**: получение астрономических координат целевого объекта (Right Ascension, Declination).
* **Verification Service → Weather Service**: получение данных о фактической облачности и прозрачности атмосферы на момент наблюдения.
* **Quest Service → Catalog Service**: валидация существования объектов при генерации миссий.

### 3.2 Асинхронное взаимодействие (RabbitMQ)
1. Пользователь сохраняет наблюдение через `Observation Service`.
2. `Observation Service` сохраняет запись в `observation_db` со статусом `PENDING`, публикует событие `observation.submitted` в exchange `polaris.events` и возвращает клиенту HTTP `202 Accepted`.
3. `Verification Service` получает событие из очереди `verification.observation_submitted`.
4. Сервис производит расчет:
   * Вычисляет гринвичское и местное звездное время ($LST$).
   * Рассчитывает высоту небесного объекта над локальным горизонтом ($Altitude$).
   * Проверяет метеоусловия через `Weather Service`.
5. По итогам проверки `Verification Service` сохраняет протокол в `verification_db` и публикует событие:
   * `observation.verified` при успехе.
   * `observation.rejected` при несоблюдении условий.
6. `Observation Service` получает результат проверки и переводит статус наблюдения в `VERIFIED` или `REJECTED`.
7. `Quest Service` слушает `observation.verified`, сопоставляет наблюдение с активными квестами пользователя и обновляет прогресс выполнения миссии.

---

## 4. Паттерны надежности и безопасности
* **Database per Service**: 7 независимых баз данных PostgreSQL (`auth_db`, `catalog_db`, `equipment_db`, `observation_db`, `quest_db`, `verification_db`, `weather_db`).
* **JWT Stateless Authentication**: токены подписываются `auth-service` и валидируются локально на микросервисах по общему ключу подписи.
* **Graceful Degradation & Fallback**: `Weather Service` при недоступности внешнего провайдера погоды переключается на кэш и локальную модель; `Verification Service` имеет локальную астрономическую базу для основных объектов.
* **Structured JSON Logging**: единый формат JSON-логов с фиксацией `timestamp`, `service`, `level`, `request_id`, `message`.
