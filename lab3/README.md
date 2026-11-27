# Лабораторная работа №3. Оркестрация микросервисов Polaris в Kubernetes / Minikube

## 1. Цель работы
Контейнеризация всех микросервисов распределенной системы Polaris и их развертывание в локальном кластере Kubernetes (Minikube) с настройкой межсервисного взаимодействия через Kubernetes Services, вынесением конфигураций в `ConfigMap`, защитой конфиденциальных данных через `Secret`, ограничением ресурсов (`resources`), проверками работоспособности (`livenessProbe`, `readinessProbe`), масштабированием (`replicas`) и самовосстановлением при сбоях.

---

## 2. Оптимизация Docker и Dockerfile

Каждый из 7 backend-микросервисов использует оптимизированный **Multi-Stage Dockerfile**:

* **Уменьшение размера образа**:
  Сборочные утилиты (`gcc`, `libpq-dev`) изолированы в промежуточном образе `builder`. В финальный образ `runner` переносятся только скомпилированные Python-библиотеки в `/usr/local` и легкие динамические библиотеки `libpq5` и `curl`.
* **Кэширование слоев**:
  Команда `COPY requirements.txt .` и установка пакетов `pip install` выполняются **до** копирования исходного кода (`COPY . .`), что ускоряет пересборку при редактировании кода.
* **Безопасность (Non-root user)**:
  Внутри контейнера создается выделенный непривилегированный системный пользователь `appuser` (UID `10001`):
  ```dockerfile
  RUN useradd -u 10001 -m -s /bin/sh appuser
  USER appuser
  ```
* **Использование `.dockerignore`**:
  Для каждого микросервиса добавлен `.dockerignore`, исключающий `__pycache__`, `.env`, `.git`, `.venv`, тестовые артефакты и кэши.
* **Отсутствие секретов в образе**:
  Никакие пароли, токены и приватные ключи не зашиты в образ. Все настройки внедряются через переменные окружения из `Secret` и `ConfigMap`.

---

## 3. Архитектура манифестов Kubernetes (`lab3/k8s/`)

Все ресурсы изолированы в пространстве имен `polaris`:

```text
lab3/k8s/
├── namespace.yaml                  # Пространство имен: polaris
├── kustomization.yaml              # Декларация всех 25 ресурсов кластера
├── configmaps/
│   ├── polaris-configmap.yaml      # Несекретные параметры (хосты, порты, URL сервисов)
│   ├── postgres-init-configmap.yaml# SQL скрипт создания 7 баз данных
│   ├── rabbitmq-configmap.yaml     # Конфигурация брокера rabbitmq.conf
│   └── gateway-configmap.yaml      # Динамическая маршрутизация Traefik
├── secrets/
│   └── polaris-secrets.yaml        # Пароли PostgreSQL, RabbitMQ и JWT_SECRET
├── deployments/
│   ├── postgres-deployment.yaml    # PostgreSQL (1 реплика, init-sql volume)
│   ├── rabbitmq-deployment.yaml    # RabbitMQ 3 Management (1 реплика)
│   ├── auth-deployment.yaml        # Auth Service (2 реплики, probes, limits)
│   ├── catalog-deployment.yaml     # Catalog Service (2 реплики, probes, limits)
│   ├── equipment-deployment.yaml   # Equipment Service (2 реплики, probes, limits)
│   ├── observation-deployment.yaml # Observation Service (2 реплики, probes, limits)
│   ├── quest-deployment.yaml       # Quest Service (2 реплики, probes, limits)
│   ├── verification-deployment.yaml# Verification Service (2 реплики, probes, limits)
│   ├── weather-deployment.yaml     # Weather Service (2 реплики, probes, limits)
│   └── gateway-deployment.yaml     # Traefik API Gateway (1 реплика)
└── services/
    ├── postgres-service.yaml       # ClusterIP :5432
    ├── rabbitmq-service.yaml       # ClusterIP :5672, :15672
    ├── auth-service.yaml           # ClusterIP :8001
    ├── catalog-service.yaml        # ClusterIP :8002
    ├── equipment-service.yaml      # ClusterIP :8003
    ├── observation-service.yaml    # ClusterIP :8004
    ├── quest-service.yaml          # ClusterIP :8005
    ├── verification-service.yaml   # ClusterIP :8006
    ├── weather-service.yaml        # ClusterIP :8007
    └── gateway-service.yaml        # NodePort :30080 (Web), :30088 (Dashboard)
```

---

## 4. Межсервисное взаимодействие через Kubernetes DNS

Сервисы **не используют `localhost`** для сетевого взаимодействия. Общение происходит через внутренний DNS Kubernetes:

* `http://auth-service:8001`
* `http://catalog-service:8002`
* `http://equipment-service:8003`
* `http://observation-service:8004`
* `http://quest-service:8005`
* `http://verification-service:8006`
* `http://weather-service:8007`
* `postgresql://postgres:***@postgres:5432/<db_name>`
* `amqp://guest:***@rabbitmq:5672/`

---

## 5. Проверки работоспособности и ограничение ресурсов

Каждый микросервис оснащен двумя типами проб:
* **`livenessProbe`**: проверяет эндпоинт `/health`. При зависании процесса Kubernetes автоматически перезапускает контейнер.
* **`readinessProbe`**: проверяет эндпоинт `/ready` (готовность БД и брокера). Трафик направляется на Pod только при положительном статусе.

### Ограничения ресурсов (Resource Limits):
* **Requests**: `cpu: 50m`, `memory: 64Mi` (гарантированный резерв).
* **Limits**: `cpu: 250m`, `memory: 256Mi` (защита от утечек памяти и зависания ноды).

---

## 6. Пошаговый запуск в Minikube

### Шаг 1: Запуск Minikube (если еще не запущен)
```powershell
minikube start --driver=docker
```

### Шаг 2: Сборка образов внутри Minikube
Для загрузки образов в Minikube без внешнего Docker Hub используется встроенный билдер:
```powershell
# PowerShell
.\lab3\docker\build-images.ps1

# Либо Bash / WSL
./lab3/docker/build-images.sh
```

### Шаг 3: Применение Kubernetes манифестов
```powershell
# Применение всей системы через Kustomize
kubectl apply -k lab3/k8s/

# Или запуск скрипта развертывания
.\lab3\scripts\deploy.ps1
```

---

## 7. Чек-лист демонстрации для защиты (7 пунктов)

Для быстрой демонстрации всех требований можно запустить готовый скрипт:
```powershell
.\lab3\scripts\demo.ps1
```

Либо выполнить шаги вручную:

### 1. Просмотр всех Pod'ов
```bash
kubectl get pods -n polaris -o wide
```
*Ожидаемый результат*: Все Pod'ы находятся в статусе `Running`, 2 реплики для каждого сервиса.

### 2. Просмотр всех Services
```bash
kubectl get services -n polaris
```
*Ожидаемый результат*: Выведен список ClusterIP сервисов для всех микросервисов и NodePort для шлюза `gateway`.

### 3. Просмотр Deployments
```bash
kubectl get deployments -n polaris
```
*Ожидаемый результат*: 10 deployments со статусом `READY` (например, `2/2` для сервисов, `1/1` для БД и шлюза).

### 4. Просмотр структурированных логов
```bash
kubectl logs -l app=catalog-service -n polaris --tail=10
```
*Ожидаемый результат*: JSON-логи с полями `timestamp`, `service`, `level`, `request_id`, `message`.

### 5. Проверка работы API
```bash
# Получение URL шлюза в Minikube
minikube service gateway -n polaris --url

# Либо через port-forward:
kubectl port-forward svc/gateway 8080:80 -n polaris

# Запросы к API через Gateway:
curl http://localhost:8080/api/catalog/objects
curl http://localhost:8080/api/weather/conditions?latitude=47.01&longitude=28.86
```

### 6. Демонстрация горизонтального масштабирования
```bash
# Масштабируем Catalog Service до 3 реплик:
kubectl scale deployment catalog-service --replicas=3 -n polaris

# Проверяем появление третьего Pod'а:
kubectl get pods -l app=catalog-service -n polaris
```

### 7. Демонстрация самовосстановления (Self-Healing)
```bash
# Выбираем один из Pod'ов Auth Service и удаляем его:
kubectl delete pod -l app=auth-service -n polaris --now

# Сразу проверяем состояние Pod'ов:
kubectl get pods -l app=auth-service -n polaris
```
*Ожидаемый результат*: Kubernetes контроллер немедленно обнаруживает исчезновение пода и запускает новый взамен удаленного, поддерживая требуемое число реплик.
