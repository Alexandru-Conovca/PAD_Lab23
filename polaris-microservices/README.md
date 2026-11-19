# Polaris Microservices — Распределённая система управления любительскими астрономическими наблюдениями

**Polaris Microservices** — серверная распределённая событийно-ориентированная архитектура для мобильного и веб-приложения Polaris. Система разработана в соответствии с требованиями курса **PAD (Proiectarea Arhitecturilor Distribuite)** на базе 7 независимых бизнес-микросервисов, API Gateway, шины сообщений RabbitMQ и изолированных баз данных PostgreSQL (паттерн **Database per Service**).

---

## 1. Архитектура системы

### Бизнес-микросервисы:
1. **Auth Service (`:8001`)**: Регистрация, авторизация, выпуск и ротация JWT access/refresh токенов, профиль пользователя (`/api/auth`).
2. **Catalog Service (`:8002`)**: Астрономический каталог планет, звёзд, галактик и туманностей, поиск, категории и избранное (`/api/catalog`).
3. **Equipment Service (`:8003`)**: Управление парком телескопов пользователя, оптическими характеристиками и выбор активного инструмента (`/api/equipment`).
4. **Observation Service (`:8004`)**: Журнал наблюдений, регистрация результатов со статусом `PENDING`, публикация событий в RabbitMQ (`/api/observations`).
5. **Quest Service (`:8005`)**: Астрономические миссии, процедурная генерация квестов, отслеживание выполнения задач и прогресса (`/api/quests`).
6. **Verification Service (`:8006`)**: Автоматическая математическая проверка видимости объекта (высота над горизонтом $Alt > 0^\circ$) и анализ облачности (`/api/verification`).
7. **Weather Service (`:8007`)**: Прогноз погоды, интеграция с Open-Meteo API и оценка прозрачности атмосферы для наблюдений (`/api/weather`).

### Инфраструктурные компоненты:
* **API Gateway (Traefik v3.6+)**: единый входной порт `8080` с автоматической маршрутизацией запросов и веб-дашбордом `8088`. Версия 3.6+ требуется для совместимости с Docker Engine 29+.
* **RabbitMQ (Topic Exchange `polaris.events`)**: асинхронный обмен событиями верификации между `Observation Service`, `Verification Service` и `Quest Service`.
* **PostgreSQL 16**: 7 независимых баз данных (`auth_db`, `catalog_db`, `equipment_db`, `observation_db`, `quest_db`, `verification_db`, `weather_db`).

---

## 2. Структура проекта

```text
polaris-microservices/
├── README.md                           # Документация проекта и инструкция по запуску
├── docker-compose.yml                  # Оркестрация 7 сервисов, Traefik, PostgreSQL и RabbitMQ
├── .env.example                        # Пример конфигурации переменных окружения
├── .gitignore
│
├── gateway/
│   └── traefik.yml                     # Статическая конфигурация Traefik API Gateway
│
├── services/
│   ├── auth-service/                   # Сервис авторизации и профилей (:8001)
│   ├── catalog-service/                # Сервис небесных объектов (:8002)
│   ├── equipment-service/              # Сервис телескопов (:8003)
│   ├── observation-service/            # Сервис журнала наблюдений (:8004)
│   ├── quest-service/                  # Сервис квестов и миссий (:8005)
│   ├── verification-service/           # Сервис проверки наблюдений (:8006)
│   └── weather-service/                # Сервис погоды и видимости (:8007)
│
├── infrastructure/
│   ├── postgres/
│   │   └── init-databases.sql          # Скрипт создания 7 баз данных
│   └── rabbitmq/
│       └── rabbitmq.conf               # Конфигурация RabbitMQ брокера
│
├── tests/
│   ├── integration/
│   │   └── test_cross_service.py       # Интеграционные тесты
│   └── e2e/
│       └── test_full_scenario.py       # E2E сквозной сценарий пользователя
│
└── docs/
    ├── architecture.md                 # Детальная архитектурная документация
    ├── api.md                          # Полная спецификация API эндпоинтов
    ├── database.md                     # Описание схемы и таблиц 7 баз данных
    └── diagrams/
        └── sequence_diagram.md         # Mermaid-диаграммы архитектуры и последовательности
```

---

## 3. Быстрый запуск через Docker Compose

### Шаг 1: Клонирование и переход в директорию
```bash
cd polaris-microservices
```

### Шаг 2: Создание файла переменных окружения
```bash
cp .env.example .env
```

### Шаг 3: Сборка и запуск всего стека
```bash
docker compose up --build -d
```

### Шаг 4: Проверка статуса контейнеров
```bash
docker compose ps
```
Все 10 контейнеров (Traefik, PostgreSQL, RabbitMQ и 7 микросервисов) должны перейти в статус `healthy` / `running`.

---

## 4. Доступные порты и веб-интерфейсы

| Компонент / Сервис | Порт хоста | Внутренний путь | Назначение |
|---|---|---|---|
| **API Gateway** | `http://localhost:8080` | `/api/*` | Единая точка входа для клиентов |
| **Traefik Dashboard** | `http://localhost:8088` | `/dashboard/` | Мониторинг маршрутов Gateway |
| **RabbitMQ Management** | `http://localhost:15672` | `/` (guest/guest) | Веб-интерфейс очередей и сообщений |
| **Auth Service Docs** | `http://localhost:8001` | `/docs` | Swagger UI сервиса авторизации |
| **Catalog Service Docs** | `http://localhost:8002` | `/docs` | Swagger UI каталога объектов |
| **Equipment Service Docs**| `http://localhost:8003` | `/docs` | Swagger UI оборудования |
| **Observation Service Docs**| `http://localhost:8004`| `/docs` | Swagger UI наблюдений |
| **Quest Service Docs** | `http://localhost:8005` | `/docs` | Swagger UI квестов |
| **Verification Service Docs**| `http://localhost:8006`| `/docs` | Swagger UI проверки |
| **Weather Service Docs** | `http://localhost:8007` | `/docs` | Swagger UI погодного сервиса |

---

## 5. Независимый локальный запуск отдельного микросервиса

Любой сервис может быть запущен автономно без Docker:

```bash
cd services/auth-service
python -m venv .venv
source .venv/bin/activate  # на Windows: .venv\Scripts\activate
pip install -r requirements.txt

# Запуск сервиса на порту 8001
uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload
```

---

## 6. Запуск тестов

```bash
# Запуск модульных тестов микросервиса
cd services/auth-service
pytest

# Запуск сквозного сценария интеграции (при запущенном стеке)
cd polaris-microservices
pytest tests/e2e/test_full_scenario.py
```

---

## 7. Событийный сценарий проверки наблюдения (RabbitMQ)

1. Клиент отправляет `POST http://localhost:8080/api/observations` с координатами и временем наблюдения.
2. `Observation Service` сохраняет статус `PENDING` и публикует событие `observation.submitted` в RabbitMQ exchange `polaris.events`.
3. `Verification Service` потребляет событие, запрашивает координаты объекта у `Catalog Service` и облачность у `Weather Service`.
4. `Verification Service` рассчитывает сферические астрономические координаты (Local Sidereal Time, Altitude) и публикует событие `observation.verified` или `observation.rejected`.
5. `Observation Service` переводит статус наблюдения в `VERIFIED` или `REJECTED`.
6. `Quest Service` принимает событие `observation.verified` и обновляет прогресс связанного квеста пользователя.
