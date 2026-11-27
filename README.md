# Polaris — Система управления любительскими астрономическими наблюдениями (UTM / PAD)

**Polaris** — распределенная модульная платформа для астрономических наблюдений любителями астрономии. Проект разработан в рамках курса **PAD (Proiectarea Arhitecturilor Distribuite)**.

---

## Структура репозитория

```text
Polaris/
├── README.md                  # Главная документация проекта
├── promt.md                   # Спецификация Лабораторной работы №2
├── promt3.md                  # Спецификация Лабораторной работы №3
│
├── lab2/                      # Лабораторная работа №2: 7 микросервисов + Docker Compose
│   ├── README.md              # Документация ЛР №2
│   ├── docker-compose.yml     # Запуск всей системы через Docker Compose
│   ├── gateway/               # Traefik API Gateway
│   ├── infrastructure/        # PostgreSQL (7 БД) + RabbitMQ
│   ├── services/              # 7 автономных бизнес-микросервисов
│   ├── tests/                 # Интеграционные и E2E тесты
│   └── docs/                  # Архитектура, API и схемы БД
│
├── lab3/                      # Лабораторная работа №3: Оркестрация в Kubernetes / Minikube
│   ├── README.md              # Документация ЛР №3 и руководство по защите
│   ├── docker/                # Скрипты сборки оптимизированных образов в Minikube
│   ├── k8s/                   # Манифесты Kubernetes (namespace: polaris)
│   │   ├── namespace.yaml
│   │   ├── kustomization.yaml
│   │   ├── configmaps/        # ConfigMaps (хосты, порты, init SQL, rabbitmq.conf, Traefik)
│   │   ├── secrets/           # Secrets (пароли БД, брокера и JWT)
│   │   ├── deployments/       # 10 Deployments (7 микросервисов + Gateway + DB + RabbitMQ)
│   │   └── services/          # 10 Services (ClusterIP + NodePort)
│   └── scripts/               # Скрипты развертывания (deploy.ps1) и защиты (demo.ps1)
│
├── polaris/                   # Мобильный клиент на Flutter (Dart)
└── backend/                   # Исходный базовый монолитный прототип
```

---

## Архитектура: 7 бизнес-микросервисов

1. **Auth Service (`:8001`)**: Аутентификация, bcrypt, JWT access/refresh токены, профили (`/api/auth`).
2. **Catalog Service (`:8002`)**: Каталог планет, звезд, галактик и туманностей, поиск и избранное (`/api/catalog`).
3. **Equipment Service (`:8003`)**: Оборудование пользователя, телескопы и оптические характеристики (`/api/equipment`).
4. **Observation Service (`:8004`)**: Журнал астрономических наблюдений, фиксация координат и времени (`/api/observations`).
5. **Quest Service (`:8005`)**: Астрономические задания, расчет прогресса и завершение квестов (`/api/quests`).
6. **Verification Service (`:8006`)**: Автоматическая проверка видимости объекта (высота над горизонтом $Alt > 0^\circ$) и облачности (`/api/verification`).
7. **Weather Service (`:8007`)**: Прогноз погоды и оценка прозрачности атмосферы для наблюдений (`/api/weather`).

---

## Быстрый старт

### Лабораторная работа №2 (Docker Compose):
```bash
cd lab2
cp .env.example .env
docker compose up --build -d
```
Подробная инструкция: [lab2/README.md](file:///c:/Users/Alexandru%20Konovka/Desktop/UTM/4Course/PAD/Polaris/lab2/README.md).

### Лабораторная работа №3 (Kubernetes / Minikube):
```powershell
# 1. Запуск кластера
minikube start --driver=docker

# 2. Сборка образов внутри Minikube
.\lab3\docker\build-images.ps1

# 3. Развертывание в Kubernetes
kubectl apply -k lab3/k8s/

# 4. Проверка и демонстрация всех 7 критериев защиты
.\lab3\scripts\demo.ps1
```
Подробная инструкция: [lab3/README.md](file:///c:/Users/Alexandru%20Konovka/Desktop/UTM/4Course/PAD/Polaris/lab3/README.md).
