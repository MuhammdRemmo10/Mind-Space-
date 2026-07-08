# MindSpace PHP Backend

Target XAMPP path:

```text
C:\xampp\htdocs\MindSpace
```

Base URL:

```text
http://localhost/MindSpace
```

## Structure

```text
api/            Public PHP endpoints
config/         Application and database configuration
controllers/    HTTP controllers
core/           Bootstrap, database, request, response, auth, validation
repositories/   Database access layer
services/       Business logic
storage/        Uploaded files
```

## Main endpoints

```text
GET  /index.php
POST /api/auth/register.php
POST /api/auth/login.php
POST /api/auth/refresh-token.php
POST /api/auth/logout.php
POST /api/auth/forgot-password.php
POST /api/auth/reset-password.php
POST /api/auth/verify-email.php
GET  /api/user/profile.php
POST /api/user/profile.php
GET  /api/dashboard/index.php
GET  /api/spaces/index.php
POST /api/spaces/index.php
GET  /api/notes/index.php
POST /api/notes/index.php
GET  /api/tasks/index.php
POST /api/tasks/index.php
GET  /api/articles/index.php
POST /api/articles/index.php
GET  /api/tags/index.php
POST /api/tags/index.php
GET  /api/files/index.php
GET  /api/search/index.php
```

Protected endpoints require:

```text
Authorization: Bearer ACCESS_TOKEN
```
