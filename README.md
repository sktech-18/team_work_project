# team_work_project

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Flutter Machine Test – Team Workspace App
**Project Overview**

Developed a Team Workspace application using Flutter,
following Clean Architecture principles with the BLoC state management pattern.
The project is designed with a scalable, modular, and maintainable architecture,
providing a responsive user experience with robust error handling,
offline support, and Firebase Authentication.

**Core Features**
Authentication
.Integrated Firebase Authentication for secure user management.
.Implemented User Registration (Sign Up) with:
 . Username
 . Email Address
 . Password
.Implemented User Sign In using email and password.
.Persisted authenticated user sessions, allowing users to remain logged 
 in after app restarts.
.Implemented secure Sign Out functionality.

**Task Management**
.Integrated task data using MockAPI.io.
.Implemented infinite scrolling (pagination) for efficient task loading.
.Added pull-to-refresh to fetch the latest task data.
.Created comprehensive UI states for:
 .Loading
 .Error handling
 .Empty state
.Implemented task creation with:
 . Task Name
 . Description
 . Priority
 . Due Date
.Enabled task editing for:
 . Task Name
 . Description
 . Priority
 . Due Date
 . Status
.Allowed users to instantly mark tasks as completed or 
 reopen completed tasks directly from the task list.

**Search & Filtering**
 Search tasks by:
 . Task Name
 . Description
 Filter tasks by:
 . Status
 . Priority
**Offline Support**
 . Implemented offline data persistence.
 . Cached task information locally to ensure data availability without an internet connection.
 . Preserved user data and synchronized the latest information whenever connectivity is restored.
**Additional Features (Optional)**
 . Implemented Dark Mode with theme switching.
 . Added Widget Tests for Splash Screen and Login modules.
 . Configured Development (Dev) and Production (Prod) flavors.
 . Maintained a clean Git history with meaningful and descriptive commit messages.
**Architecture & Technical Highlights**
 . Clean Architecture with clear separation of Presentation, Domain, 
   and Data layers.
 . Feature-based, modular project structure for improved scalability 
   and maintainability.
 . State management using the BLoC Pattern.
 . Responsive UI optimized for different screen sizes.
 . REST API integration using MockAPI.io.
 . Secure authentication using Firebase Authentication.
 . Robust error handling and state management throughout the application.
 . Designed with reusable widgets, clean coding practices,
    and maintainable code structure.

Created googleServices.json added sha key for firebase authentication.



