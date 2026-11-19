# Polaris

Polaris is a Flutter astronomy companion for planning and recording observations.

## Backend

The app talks to the Polaris microservices through the API Gateway:

```bash
cd ../polaris-microservices
docker compose up --build -d
```

The gateway is available at `http://localhost:8080`.

## Running the app

```bash
flutter pub get
flutter run
```

Default API base URLs:

- Android emulator: `http://10.0.2.2:8080`
- Desktop/web/other platforms: `http://localhost:8080`

For a physical Android device or another host, pass the machine IP explicitly:

```bash
flutter run --dart-define=POLARIS_API_BASE_URL=http://192.168.1.10:8080
```
