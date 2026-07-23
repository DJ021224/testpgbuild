# testpgbuild — End-to-End Build Process Guide

> **Reusable reference for every new PostgreSQL build pipeline.**
> Covers local setup, CI/CD, versioned migrations, rollback, and troubleshooting.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Repository Structure](#3-repository-structure)
4. [Configuration](#4-configuration)
5. [Jenkins Setup](#5-jenkins-setup)
6. [Build Stages Explained](#6-build-stages-explained)
7. [Running Locally](#7-running-locally)
8. [Adding a New Migration](#8-adding-a-new-migration)
9. [Adding a New Database Object](#9-adding-a-new-database-object)
10. [Rollback Procedure](#10-rollback-procedure)
11. [Seeding Data](#11-seeding-data)
12. [Running Tests](#12-running-tests)
13. [Starting a New Project from This Template](#13-starting-a-new-project-from-this-template)
14. [Troubleshooting](#14-troubleshooting)

---

## 1. Overview

This pipeline manages the **complete lifecycle** of a PostgreSQL database as code:

```
Git Push
  │
  └── Jenkins Pipeline
        ├── Stage 1 : Checkout        — pull latest code
        ├── Stage 2 : Validate        — check tools & connectivity
        ├── Stage 3 : Database Setup  — create DB + migration tracker
        ├── Stage 4 : Migrations      — apply pending V*.sql files
        ├── Stage 5 : Deploy Objects  — procedures, functions, views
        ├── Stage 6 : Seed Data       — sample data (dev only)
        └── Stage 7 : Tests           — unit + integration SQL tests
```

**Technology stack:**

| Component       | Choice                          |
|-----------------|----------------------------------|
| Database        | PostgreSQL                       |
| CI/CD           | Jenkins (Windows agent)          |
| Scripting       | PowerShell 5+                    |
| Migration style | Version-ordered SQL files (V###) |
| Source control  | Git (GitHub/Bitbucket/GitLab)    |

---

## 2. Prerequisites

Install and configure the following **on the Windows machine** running Jenkins (or your local machine for local runs):

### 2.1 PostgreSQL Client Tools

1. Download PostgreSQL for Windows from https://www.postgresql.org/download/windows/
2. During install, ensure **Command Line Tools** component is selected.
3. Add `C:\Program Files\PostgreSQL\<version>\bin` to your system `PATH`.
4. Verify: open PowerShell and run:
   ```powershell
   psql --version
   ```
   Expected output: `psql (PostgreSQL) 15.x` (or your installed version).

### 2.2 PostgreSQL Server

Ensure PostgreSQL is running and accessible:

```powershell
# Test connectivity (replace values as needed)
$env:PGPASSWORD = 'admin@123'
psql -h localhost -U admin -d postgres -c "SELECT version();"
```

### 2.3 Jenkins

- Jenkins 2.x+ installed and running on Windows.
- Plugins required:
  - **Pipeline** (built-in)
  - **Credentials Binding Plugin**
  - **Git Plugin**
- **Execution Policy** (PowerShell): ensure Jenkins agent can run `.ps1` files:
  ```powershell
  Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
  ```

### 2.4 Git

- Git for Windows installed.
- Repository cloned to `D:\testpgbuild` (or adjust `ROOT_DIR` in `build.ps1`).

---

## 3. Repository Structure

```
testpgbuild/
│
├── Jenkinsfile                          ← CI/CD pipeline definition
│
├── config/
│   ├── dev.env                          ← Dev credentials (committed)
│   ├── staging.env.template             ← Template (committed; copy & fill)
│   └── prod.env.template                ← Template (committed; copy & fill)
│
├── database/
│   ├── migrations/                      ← Versioned schema changes
│   │   ├── V001__init_migration_tracker.sql
│   │   ├── V002__create_chinook_schema.sql
│   │   └── V003__create_indexes.sql
│   │
│   ├── procedures/                      ← Stored procedures (idempotent)
│   │   └── employee_dj.sql
│   │
│   ├── functions/                       ← PostgreSQL functions (idempotent)
│   │   └── get_employee_count.sql
│   │
│   ├── views/                           ← Database views (idempotent)
│   │   └── vw_invoice_summary.sql
│   │
│   ├── seeds/                           ← Sample / reference data
│   │   └── 01_chinook_sample_data.sql
│   │
│   └── rollback/                        ← Undo scripts matching migrations
│       ├── R002__drop_chinook_schema.sql
│       └── R003__drop_indexes.sql
│
├── scripts/
│   ├── build/
│   │   ├── build.ps1                    ← MASTER orchestrator (run this)
│   │   └── validate.ps1                 ← Pre-flight checks
│   │
│   ├── deploy/
│   │   ├── setup-database.ps1           ← Create DB + migration table
│   │   ├── deploy-migrations.ps1        ← Apply pending migrations
│   │   ├── deploy-objects.ps1           ← Apply procedures/functions/views
│   │   ├── deploy-seeds.ps1             ← Seed sample data
│   │   └── rollback.ps1                 ← Rollback N migrations
│   │
│   ├── test/
│   │   ├── test-connection.ps1          ← Smoke test
│   │   └── run-tests.ps1               ← Run all SQL test suites
│   │
│   └── utils/
│       ├── logger.ps1                   ← Logging module
│       └── common.ps1                   ← Shared DB helper functions
│
├── tests/
│   ├── unit/
│   │   └── test_procedures.sql          ← Procedure/function unit tests
│   └── integration/
│       └── test_data_integrity.sql      ← Schema + data integrity tests
│
├── logs/                                ← Build logs (gitignored)
├── docs/
│   └── BUILD_PROCESS.md                 ← This file
├── .gitignore
├── CHANGELOG.md
└── README.md
```

---

## 4. Configuration

### 4.1 Dev Environment (Local)

Edit `config/dev.env`:

```ini
DB_HOST=localhost
DB_PORT=5432
DB_USER=admin
DB_PASSWORD=admin@123
DB_NAME=chinook
```

`build.ps1` automatically loads this file when `-Environment dev` (the default).

### 4.2 Staging / Prod

1. Copy the template:
   ```powershell
   Copy-Item config\staging.env.template config\staging.env
   ```
2. Fill in the real values.
3. **Do not commit** `staging.env` or `prod.env` — they are gitignored.
4. For Jenkins builds, use Jenkins Credentials (see §5).

---

## 5. Jenkins Setup

### 5.1 Create Credentials

In Jenkins → **Manage Jenkins → Credentials → System → Global**:

| Credential ID       | Kind                   | Value                       |
|---------------------|------------------------|-----------------------------|
| `chinook-db-creds`  | Username with password | Username: `admin` / Password: `admin@123` |
| `chinook-db-host`   | Secret text            | `localhost` (or your DB host)|

### 5.2 Create Pipeline Job

1. New Item → **Pipeline** → Name: `testpgbuild`
2. Pipeline → Definition: **Pipeline script from SCM**
3. SCM: **Git**, Repository URL: your repo URL
4. Script Path: `Jenkinsfile`
5. Save & Build.

### 5.3 Pipeline Parameters

When triggering a build you can set:

| Parameter        | Default | Description                                      |
|------------------|---------|--------------------------------------------------|
| `ENVIRONMENT`    | `dev`   | `dev` / `staging` / `prod`                       |
| `SKIP_SEED`      | false   | Skip seeding (recommended for staging/prod)      |
| `SKIP_TESTS`     | false   | Skip test suites                                 |
| `DRY_RUN`        | false   | Preview migrations without applying              |
| `ROLLBACK`       | false   | Roll back instead of deploying                   |
| `ROLLBACK_STEPS` | `1`     | Number of versions to roll back                  |

---

## 6. Build Stages Explained

### Stage 1 — Checkout
Pulls the latest code from the configured Git branch. Prints branch name and commit SHA for traceability.

### Stage 2 — Validate (`scripts/build/validate.ps1`)
- Confirms `psql` is in `PATH`.
- Tests the PostgreSQL connection with the provided credentials.
- Scans `database/migrations/` to ensure `V*.sql` files exist and are non-empty.
- **If any check fails, the pipeline aborts here** — nothing is written to the database.

### Stage 3 — Database Setup (`scripts/deploy/setup-database.ps1`)
- Creates the `chinook` database if it does not exist (`CREATE DATABASE`).
- Creates the `schema_migrations` tracking table if it does not exist.

### Stage 4 — Migrations (`scripts/deploy/deploy-migrations.ps1`)
- Reads all `V*.sql` files from `database/migrations/` sorted by version.
- Queries `schema_migrations` to identify already-applied versions.
- Applies only **pending** (unapplied) migrations in order.
- Records each applied migration (version, description, checksum, execution time).
- Stops on first failure (`ON_ERROR_STOP=1`).

### Stage 5 — Deploy Objects (`scripts/deploy/deploy-objects.ps1`)
- Applies all files in `database/functions/`, `database/procedures/`, `database/views/` **in that order** (dependency order).
- All SQL uses `CREATE OR REPLACE` so this stage is safe to re-run.

### Stage 6 — Seed Data (`scripts/deploy/deploy-seeds.ps1`)
- Skipped if `artist` table already has rows (unless `-Force`).
- Applies seed files from `database/seeds/` in numeric name order.
- Uses `ON CONFLICT DO NOTHING` — safe to re-run.

### Stage 7 — Tests
- **test-connection.ps1**: Verifies psql, connection, DB existence, and all 10 tables.
- **run-tests.ps1**: Runs `tests/unit/test_*.sql` then `tests/integration/test_*.sql`. Each SQL file is a `DO $$…$$` block that raises `EXCEPTION` on failure.

---

## 7. Running Locally

Open **PowerShell** in `D:\testpgbuild`.

### Full build (default dev)
```powershell
.\scripts\build\build.ps1
```

### Full build with explicit credentials
```powershell
.\scripts\build\build.ps1 `
    -DBHost localhost -DBPort 5432 `
    -DBUser admin -DBPassword 'admin@123' `
    -DBName chinook
```

### Dry-run (preview migrations only)
```powershell
.\scripts\build\build.ps1 -DryRun
```

### Skip seed data
```powershell
.\scripts\build\build.ps1 -SkipSeed
```

### Run only migrations (no full build)
```powershell
.\scripts\deploy\deploy-migrations.ps1 `
    -DBHost localhost -DBUser admin -DBPassword 'admin@123'
```

### Run tests only
```powershell
.\scripts\test\run-tests.ps1 `
    -DBHost localhost -DBUser admin -DBPassword 'admin@123'
```

---

## 8. Adding a New Migration

1. Determine the next version number (e.g., current highest is `003` → use `004`).
2. Create the file:
   ```
   database\migrations\V004__your_description_here.sql
   ```
   Use underscores in the description, no spaces.
3. Write the SQL (always use `IF NOT EXISTS` / `IF EXISTS` guards where appropriate).
4. Create the matching rollback script:
   ```
   database\rollback\R004__your_description_here.sql
   ```
5. Commit and push — the pipeline will pick it up automatically.

**Naming convention:**
```
V<zero-padded-3-digit-version>__<description_with_underscores>.sql
R<zero-padded-3-digit-version>__<description_with_underscores>.sql
```

---

## 9. Adding a New Database Object

### Stored Procedure
1. Create `database\procedures\my_new_proc.sql`
2. Write `CREATE OR REPLACE PROCEDURE …`
3. The `deploy-objects.ps1` stage picks it up on the next build.

### Function
1. Create `database\functions\my_new_func.sql`
2. Write `CREATE OR REPLACE FUNCTION …`

### View
1. Create `database\views\vw_my_view.sql`
2. Write `CREATE OR REPLACE VIEW …`

> Objects are always deployed **after** migrations, so they can reference any newly created tables.

---

## 10. Rollback Procedure

### Roll back last migration (via script)
```powershell
.\scripts\deploy\rollback.ps1 `
    -DBHost localhost -DBUser admin -DBPassword 'admin@123'
```

### Roll back last 2 migrations
```powershell
.\scripts\deploy\rollback.ps1 `
    -DBHost localhost -DBUser admin -DBPassword 'admin@123' `
    -Steps 2
```

### Roll back a specific version
```powershell
.\scripts\deploy\rollback.ps1 `
    -DBHost localhost -DBUser admin -DBPassword 'admin@123' `
    -Version 003
```

### Via Jenkins
Set parameter `ROLLBACK = true` and `ROLLBACK_STEPS = 1` when triggering the pipeline.

**What happens:**
1. The script locates `database\rollback\R<version>__*.sql`.
2. Runs the SQL against the database.
3. Removes the version entry from `schema_migrations`.

---

## 11. Seeding Data

Seed files live in `database/seeds/` and are applied in alphabetical order (`01_`, `02_`, …).

### Force re-seed (even if data exists)
```powershell
.\scripts\deploy\deploy-seeds.ps1 `
    -DBHost localhost -DBUser admin -DBPassword 'admin@123' `
    -Force
```

### Adding new seed data
1. Create `database\seeds\02_my_reference_data.sql`
2. Use `ON CONFLICT (id) DO NOTHING` to keep it idempotent.

---

## 12. Running Tests

### All suites
```powershell
.\scripts\test\run-tests.ps1 `
    -DBHost localhost -DBUser admin -DBPassword 'admin@123'
```

### Unit tests only
```powershell
.\scripts\test\run-tests.ps1 `
    -DBHost localhost -DBUser admin -DBPassword 'admin@123' `
    -Suite unit
```

### Integration tests only
```powershell
.\scripts\test\run-tests.ps1 `
    -DBHost localhost -DBUser admin -DBPassword 'admin@123' `
    -Suite integration
```

### Adding a test
1. Create `tests\unit\test_my_feature.sql` or `tests\integration\test_my_feature.sql`.
2. Structure it as a `DO $$ … $$` block.
3. Use `RAISE EXCEPTION 'FAIL: …'` on assertion failure.
4. Use `RAISE NOTICE 'PASS: …'` on success.
5. The test runner detects `FAIL` in output automatically.

---

## 13. Starting a New Project from This Template

Follow these steps every time you start a new PostgreSQL build project:

1. **Create a new Git repository** and clone it locally.

2. **Copy the full folder structure** from `testpgbuild` (excluding `.git/`, `logs/`, `*.env`):
   ```powershell
   $src  = 'D:\testpgbuild'
   $dest = 'D:\mynewproject'
   Copy-Item -Recurse -Path $src -Destination $dest -Exclude '.git','logs','*.log'
   ```

3. **Update `config\dev.env`** with your new database credentials.

4. **Rename the database** in all config files and build scripts:
   - `config\dev.env` → `DB_NAME=mynewdb`
   - `scripts\build\build.ps1` → default `-DBName`
   - `scripts\*\*.ps1` → update `-DBName` default param

5. **Replace migrations** — delete `V002__create_chinook_schema.sql` and create your own `V002__create_<project>_schema.sql`.

6. **Replace seeds** in `database\seeds\`.

7. **Update tests** in `tests\unit\` and `tests\integration\`.

8. **Create Jenkins credentials** for the new project (see §5.1).

9. **Create Jenkins pipeline job** pointing to the new repo.

10. Run the pipeline — done!

---

## 14. Troubleshooting

### `psql: command not found`
- Add PostgreSQL `bin` directory to system PATH.
- Restart PowerShell / Jenkins agent after updating PATH.

### `FATAL: password authentication failed for user "admin"`
- Verify the password in `config\dev.env` or Jenkins credentials.
- Check `pg_hba.conf` allows `md5` or `scram-sha-256` auth for the user.

### Migration fails with `ERROR: relation "X" already exists`
- The SQL likely lacks `IF NOT EXISTS`. Add it, or make the migration check for pre-existing objects.
- Alternatively, the migration may have partially run before. Check `schema_migrations` for partial records.

### `schema_migrations` table does not exist
- Run Stage 3 (Database Setup) manually:
  ```powershell
  .\scripts\deploy\setup-database.ps1 -DBHost localhost -DBUser admin -DBPassword 'admin@123'
  ```

### Jenkins pipeline fails with `execution of scripts is disabled`
```powershell
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
```
Run this on the Jenkins agent machine as Administrator.

### Seed data not loading
- Check that `artist` table exists (run migrations first).
- If data already exists, use `-Force` flag with `deploy-seeds.ps1`.

### Tests fail with `FAIL: X table is empty`
- Seeds may not have run. Execute Stage 6 manually:
  ```powershell
  .\scripts\deploy\deploy-seeds.ps1 -DBHost localhost -DBUser admin -DBPassword 'admin@123' -Force
  ```

### How to check what migrations have been applied
```powershell
$env:PGPASSWORD = 'admin@123'
psql -h localhost -U admin -d chinook -c "SELECT version, description, applied_at FROM schema_migrations ORDER BY version;"
```

---

*Generated by Claude Code — testpgbuild project | Last updated: 2026-07-23*
