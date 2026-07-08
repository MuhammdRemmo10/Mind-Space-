# MindSpace

MindSpace is a Flutter personal knowledge management system built around Spaces.
It is designed to organize notes, tasks, articles, files, tags, public content,
statistics, reminders, security, synchronization, and future AI workflows.

## Backend

PHP API document root:

```text
C:\xampp\htdocs\MindSpace
```

Default local API base URL:

```text
http://localhost/MindSpace
```

Android emulator API base URL:

```text
http://10.0.2.2/MindSpace
```

## Architecture

The application follows:

- Clean Architecture
- Feature-First Architecture
- SOLID Principles
- Repository Pattern
- Dependency Injection with GetIt
- Cubit with flutter_bloc
- Dio REST client
- Equatable entities and states
- Material 3 design system
- Responsive layout with Flutter ScreenUtil
- Offline-first preparation
- Future AI integration preparation

## Main folders

```text
lib/src/app
lib/src/core
lib/src/features
lib/src/shared
```

Each feature is structured independently with domain, data, and presentation
layers where needed.

## Backend source

The PHP backend source is kept in:

```text
backend/
```

The same files are copied to the XAMPP document root when running locally.
