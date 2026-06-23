# Courtly Mobile App

Courtly es una aplicación móvil desarrollada en Flutter para jugadores y entrenadores. La app permite iniciar sesión, registrar cuentas, visualizar perfiles, buscar canchas, ver el detalle de una cancha y conectar funcionalidades con el backend de Courtly.

Este proyecto usa una arquitectura basada en **Domain-Driven Design (DDD)**, separando las funcionalidades principales por **Bounded Contexts**.

---

## Tecnologías utilizadas

- Flutter
- Dart
- Android Studio / IntelliJ IDEA
- Spring Boot Backend
- MySQL
- REST API
- Shared Preferences
- HTTP Client

---

## Estructura principal del proyecto

```text
lib/
├── app/
│   ├── courtly_app.dart
│   ├── routes/
│   └── theme/
│
├── shared/
│   ├── infrastructure/
│   │   ├── http/
│   │   └── storage/
│   └── presentation/
│       └── widgets/
│
└── contexts/
    ├── iam/
    ├── users/
    ├── courts/
    ├── bookings/
    ├── matches/
    ├── coaches/
    ├── availabilities/
    ├── payments/
    ├── reviews/
    ├── notifications/
    └── analytics/
```
---
## Core

bookings       -> reservas de canchas<br>
matches        -> organización de partidos<br>
courts         -> catálogo y detalle de canchas<br>
coaches        -> catálogo de entrenadores

## Supporting

availabilities -> disponibilidad de horarios<br>
payments       -> pagos<br>
reviews        -> reseñas<br>
notifications  -> notificaciones<br>
analytics      -> métricas

## Generic

iam            -> autenticación y registro<br>
users          -> perfil del usuario


# Requisitos previos

Antes de ejecutar el proyecto, debe tener instalado:

Flutter SDK
Dart SDK
Android Studio o IntelliJ IDEA
Java 21 o superior
Maven
MySQL Server
MySQL Command Line Client o MySQL Workbench
Git

## Verificar instalación de Flutter:

flutter doctor<br>

## Verificar dispositivos disponibles:
flutter devices

## Instalar dependencias:
flutter pub add http shared_preferences
flutter pub get