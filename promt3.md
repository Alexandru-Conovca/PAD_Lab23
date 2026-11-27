Лабораторная работа №3. Docker и Kubernetes
1. Цель работы
В третьей лабораторной необходимо взять приложение из лабораторной работы №2, контейнеризировать его и развернуть с использованием системы оркестрации контейнеров.

Допускается использовать:

Kubernetes;
Minikube.
2. Docker
Каждый backend-микросервис должен быть контейнеризирован.

Например:

Auth Service
      ↓
Docker Image

User Service
      ↓
Docker Image

Order Service
      ↓
Docker Image

...
Для каждого сервиса необходимо предоставить Dockerfile.

3. Dockerfile
Dockerfile должен быть оптимизирован.

Необходимо учитывать:

небольшой размер image;
использование .dockerignore;
caching слоёв;
отсутствие секретов внутри image;
запуск приложения не от root, если это возможно;
корректный CMD/ENTRYPOINT.
Пример структуры:

service/
├── Dockerfile
├── .dockerignore
├── requirements.txt
└── src/
4. Docker Compose
Перед Kubernetes рекомендуется проверить приложение через Docker Compose.

Пример:

docker-compose.yml

        ┌──────────────┐
        │ API Gateway  │
        └───────┬──────┘
                │
     ┌──────────┼──────────┐
     ▼          ▼          ▼
   Auth       User       Order
 Service     Service     Service
     │          │          │
     ▼          ▼          ▼
   DB/Auth    DB/User    DB/Order
Compose должен позволять поднять всю систему одной командой.

Например:

docker compose up --build
5. Kubernetes
Необходимо подготовить Kubernetes manifests.

Минимально рекомендуется использовать:

Deployment
Service
ConfigMap
Secret
Для каждого backend-сервиса должен существовать Kubernetes Deployment.

Например:

k8s/
├── namespace.yaml
├── auth/
│   ├── deployment.yaml
│   └── service.yaml
├── user/
│   ├── deployment.yaml
│   └── service.yaml
├── order/
│   ├── deployment.yaml
│   └── service.yaml
├── payment/
│   ├── deployment.yaml
│   └── service.yaml
├── notification/
│   ├── deployment.yaml
│   └── service.yaml
├── gateway/
│   ├── deployment.yaml
│   └── service.yaml
├── configmap.yaml
└── secret.yaml
Структура может отличаться.

6. Deployment
Для каждого сервиса необходимо создать Deployment.

Deployment должен описывать:

Docker image;
количество replicas;
container port;
environment variables;
resources;
health checks.
Например:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
        - name: user-service
          image: user-service:latest
          ports:
            - containerPort: 8000
7. Kubernetes Service
Для взаимодействия между сервисами необходимо использовать Kubernetes Services.

Например:

order-service
      │
      │ HTTP
      ▼
payment-service
В Kubernetes:

http://payment-service:8000
Сервисы не должны обращаться друг к другу через localhost.

8. ConfigMap
Конфигурационные параметры необходимо вынести из Docker image.

Например:

DATABASE_HOST
DATABASE_PORT
LOG_LEVEL
SERVICE_URL
должны задаваться через environment variables / ConfigMap.

9. Secrets
Пароли, токены и другие секретные значения нельзя хранить непосредственно в исходном коде.

Например:

DATABASE_PASSWORD
JWT_SECRET
API_KEY
не должны находиться в Git в открытом виде.

Для Kubernetes необходимо использовать Secret.

10. Health Checks
Каждый сервис должен иметь health endpoints.

Например:

/health
/ready
В Kubernetes необходимо использовать:

livenessProbe
readinessProbe
Пример:

livenessProbe:
  httpGet:
    path: /health
    port: 8000

readinessProbe:
  httpGet:
    path: /ready
    port: 8000
11. Resource Limits
Для контейнеров необходимо задать ограничения ресурсов.

Например:

resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
Конкретные значения должны зависеть от вашего приложения.

12. Масштабирование
Необходимо продемонстрировать возможность горизонтального масштабирования хотя бы одного сервиса.

Например:

kubectl scale deployment order-service --replicas=3
После этого:

             ┌─ order-service
             │
Request ─────┼─ order-service
             │
             └─ order-service
13. Запуск в Minikube
Пример последовательности запуска:

minikube start
Далее необходимо загрузить/собрать Docker images.

После этого:

kubectl apply -f k8s/
Проверка:

kubectl get pods
kubectl get services
kubectl get deployments
14. Демонстрация работы
Во время защиты необходимо показать:

1. Все Pod'ы
kubectl get pods
2. Все Services
kubectl get services
3. Deployments
kubectl get deployments
4. Логи
kubectl logs <pod>
5. Работа API
Необходимо выполнить несколько реальных запросов к приложению.

6. Масштабирование
Показать изменение количества replicas.

7. Восстановление
Желательно удалить один Pod:

kubectl delete pod <pod>
и показать, что Kubernetes автоматически создаёт новый Pod.

15. Что необходимо предоставить
Пример итоговой структуры репозитория:

project/
│
├── README.md
│
├── lab2/
│   ├── README.md
│   ├── gateway/
│   ├── services/
│   ├── tests/
│   └── docker-compose.yml
│
└── lab3/
    ├── README.md
    ├── docker/
    └── k8s/
        ├── namespace.yaml
        ├── deployments/
        ├── services/
        ├── configmaps/
        └── secrets/