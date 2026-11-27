# Базы данных Polaris Microservices (Database per Service)

Каждый микросервис владеет собственной изолированной базой данных. В Docker-окружении все базы данных размещены в экземпляре PostgreSQL и инициализируются скриптом `infrastructure/postgres/init-databases.sql`.

---

## 1. auth_db (Auth Service)
* **`accounts`**:
  * `id`: SERIAL PRIMARY KEY
  * `email`: VARCHAR(255) UNIQUE NOT NULL
  * `password_hash`: VARCHAR(255) NOT NULL
  * `full_name`: VARCHAR(255) NOT NULL
  * `role`: VARCHAR(50) DEFAULT 'user'
  * `created_at`, `updated_at`: TIMESTAMPTZ NOT NULL
* **`refresh_tokens`**:
  * `id`: SERIAL PRIMARY KEY
  * `user_id`: INTEGER REFERENCES accounts(id) ON DELETE CASCADE
  * `token`: VARCHAR(255) UNIQUE NOT NULL
  * `expires_at`: TIMESTAMPTZ NOT NULL
  * `revoked`: BOOLEAN DEFAULT FALSE
  * `created_at`: TIMESTAMPTZ NOT NULL

---

## 2. catalog_db (Catalog Service)
* **`object_categories`**:
  * `id`: VARCHAR(50) PRIMARY KEY (planets, galaxies, nebulae, stars)
  * `name`: VARCHAR(100) NOT NULL
  * `description`: TEXT
* **`celestial_objects`**:
  * `id`: VARCHAR(50) PRIMARY KEY (mars, saturn, m31, etc.)
  * `name`: VARCHAR(150) NOT NULL
  * `type`: VARCHAR(50) NOT NULL
  * `category_id`: VARCHAR(50) REFERENCES object_categories(id)
  * `description`: TEXT NOT NULL
  * `magnitude`: FLOAT NOT NULL
  * `right_ascension`: FLOAT NOT NULL (в градусах)
  * `declination`: FLOAT NOT NULL (в градусах)
  * `coordinates_str`: VARCHAR(100) NOT NULL
  * `constellation`: VARCHAR(100) NOT NULL
  * `is_visible_now`: BOOLEAN NOT NULL DEFAULT TRUE
  * `created_at`: TIMESTAMPTZ NOT NULL
* **`favorites`**:
  * `id`: SERIAL PRIMARY KEY
  * `user_id`: INTEGER NOT NULL
  * `object_id`: VARCHAR(50) REFERENCES celestial_objects(id) ON DELETE CASCADE
  * `created_at`: TIMESTAMPTZ NOT NULL
  * UNIQUE(user_id, object_id)

---

## 3. equipment_db (Equipment Service)
* **`telescopes`**:
  * `id`: SERIAL PRIMARY KEY
  * `user_id`: INTEGER NOT NULL
  * `name`: VARCHAR(150) NOT NULL
  * `aperture`: INTEGER NOT NULL (в мм)
  * `focal_length`: INTEGER NOT NULL (в мм)
  * `mount_type`: VARCHAR(100) NOT NULL
  * `is_active`: BOOLEAN DEFAULT FALSE
  * `notes`: TEXT
  * `created_at`, `updated_at`: TIMESTAMPTZ NOT NULL

---

## 4. observation_db (Observation Service)
* **`observations`**:
  * `id`: SERIAL PRIMARY KEY
  * `user_id`: INTEGER NOT NULL
  * `celestial_object_id`: VARCHAR(50) NOT NULL
  * `telescope_id`: INTEGER
  * `quest_id`: VARCHAR(50)
  * `observed_at`: TIMESTAMPTZ NOT NULL
  * `latitude`: FLOAT NOT NULL
  * `longitude`: FLOAT NOT NULL
  * `location_name`: VARCHAR(150)
  * `status`: VARCHAR(50) NOT NULL DEFAULT 'PENDING'
  * `notes`: TEXT
  * `verification_score`: FLOAT
  * `verification_reason`: TEXT
  * `created_at`, `updated_at`: TIMESTAMPTZ NOT NULL

---

## 5. quest_db (Quest Service)
* **`quests`**:
  * `id`: VARCHAR(50) PRIMARY KEY
  * `title`: VARCHAR(150) NOT NULL
  * `description`: TEXT NOT NULL
  * `difficulty`: VARCHAR(50) DEFAULT 'beginner'
  * `tasks_count`: INTEGER DEFAULT 1
  * `reward_xp`: INTEGER DEFAULT 100
  * `created_at`: TIMESTAMPTZ NOT NULL
* **`quest_tasks`**:
  * `id`: SERIAL PRIMARY KEY
  * `quest_id`: VARCHAR(50) REFERENCES quests(id) ON DELETE CASCADE
  * `step_order`: INTEGER NOT NULL DEFAULT 1
  * `title`: VARCHAR(150) NOT NULL
  * `target_object_id`: VARCHAR(50) NOT NULL
  * `target_object_name`: VARCHAR(150) NOT NULL
  * `description`: TEXT
* **`user_quests`**:
  * `id`: SERIAL PRIMARY KEY
  * `user_id`: INTEGER NOT NULL
  * `quest_id`: VARCHAR(50) REFERENCES quests(id) ON DELETE CASCADE
  * `status`: VARCHAR(50) DEFAULT 'in_progress'
  * `progress_percent`: FLOAT DEFAULT 0.0
  * `started_at`: TIMESTAMPTZ NOT NULL
  * `completed_at`: TIMESTAMPTZ
* **`quest_progress`**:
  * `id`: SERIAL PRIMARY KEY
  * `user_quest_id`: INTEGER REFERENCES user_quests(id) ON DELETE CASCADE
  * `task_id`: INTEGER REFERENCES quest_tasks(id) ON DELETE CASCADE
  * `is_completed`: BOOLEAN DEFAULT FALSE
  * `completed_at`: TIMESTAMPTZ

---

## 6. verification_db (Verification Service)
* **`verification_rules`**:
  * `id`: SERIAL PRIMARY KEY
  * `rule_name`: VARCHAR(100) UNIQUE NOT NULL
  * `description`: TEXT NOT NULL
  * `threshold_value`: FLOAT NOT NULL
  * `is_active`: BOOLEAN DEFAULT TRUE
* **`verification_requests`**:
  * `id`: SERIAL PRIMARY KEY
  * `observation_id`: INTEGER NOT NULL
  * `user_id`: INTEGER NOT NULL
  * `celestial_object_id`: VARCHAR(50) NOT NULL
  * `latitude`: FLOAT NOT NULL
  * `longitude`: FLOAT NOT NULL
  * `observed_at`: TIMESTAMPTZ NOT NULL
  * `status`: VARCHAR(50) NOT NULL DEFAULT 'PROCESSING'
  * `created_at`: TIMESTAMPTZ NOT NULL
* **`verification_results`**:
  * `id`: SERIAL PRIMARY KEY
  * `request_id`: INTEGER REFERENCES verification_requests(id) ON DELETE CASCADE
  * `observation_id`: INTEGER NOT NULL
  * `is_valid`: BOOLEAN NOT NULL
  * `status`: VARCHAR(50) NOT NULL
  * `score`: FLOAT NOT NULL
  * `details_json`: TEXT
  * `reasons`: TEXT NOT NULL
  * `verified_at`: TIMESTAMPTZ NOT NULL

---

## 7. weather_db (Weather Service)
* **`weather_forecasts`**:
  * `id`: SERIAL PRIMARY KEY
  * `latitude`: FLOAT NOT NULL
  * `longitude`: FLOAT NOT NULL
  * `recorded_at`: TIMESTAMPTZ NOT NULL
  * `temperature`: FLOAT NOT NULL
  * `cloud_cover`: FLOAT NOT NULL
  * `relative_humidity`: FLOAT NOT NULL
  * `visibility`: FLOAT
  * `wind_speed`: FLOAT
  * `source`: VARCHAR(50) NOT NULL
* **`observation_conditions`**:
  * `id`: SERIAL PRIMARY KEY
  * `latitude`: FLOAT NOT NULL
  * `longitude`: FLOAT NOT NULL
  * `timestamp`: TIMESTAMPTZ NOT NULL
  * `cloud_cover`: FLOAT NOT NULL
  * `suitability_score`: FLOAT NOT NULL
  * `rating`: VARCHAR(50) NOT NULL
  * `summary`: TEXT NOT NULL
