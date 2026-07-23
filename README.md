# testpgbuild

End-to-end PostgreSQL database build pipeline — Windows / Jenkins / PowerShell.

## Quick Start (Local)

```powershell
# Full build — creates DB, runs migrations, deploys objects, seeds data, runs tests
.\scripts\build\build.ps1
```

## Documentation

See **[docs/BUILD_PROCESS.md](docs/BUILD_PROCESS.md)** for the complete guide covering:
- Prerequisites and setup
- All build stages explained
- Adding migrations and database objects
- Rollback procedures
- Starting a new project from this template
- Troubleshooting

## Database

| Setting  | Value      |
|----------|------------|
| Name     | `chinook`  |
| User     | `admin`    |
| Host     | `localhost`|
| Port     | `5432`     |

## Project Structure

```
scripts/build/      — orchestrator + validation
scripts/deploy/     — migrations, objects, seeds, rollback
scripts/test/       — connection smoke test + test runner
scripts/utils/      — logger + shared DB helpers
database/migrations — versioned V*.sql schema changes
database/procedures — stored procedures
database/functions  — reusable SQL functions
database/views      — reporting views
database/seeds      — sample data
database/rollback   — undo scripts (R*.sql)
tests/unit          — procedure/function unit tests
tests/integration   — schema and data integrity tests
config/             — environment configs
docs/               — documentation
```
