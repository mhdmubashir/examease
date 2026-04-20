📌 Full System Workflow & Architecture View
1️⃣ System Overview

The Exam SaaS Mobile App is a dynamic, configuration-driven content engine:

Backend-controlled, no hardcoding of exams, modules, or content.

Supports new content types like PRACTICE_SET, VIDEO, PDF without app update.

Modular, scalable, offline-friendly (optional), and secure.

Handles 100k+ users, with caching, lazy loading, and optimized network usage.

Payment-enabled modules unlock via verified backend confirmation.

Mock tests with timer, offline caching, and anti-cheat mechanisms.

2️⃣ Layered Architecture (Clean Architecture)
2.1 Presentation Layer

UI Widgets

BLoC / Cubit for state management

GoRouter for navigation

Responsiveness & lazy loading

Rules:

No business logic in UI

UI only subscribes to BLoC state

BLoC calls Domain Layer use cases (never API directly)

Widgets consume Entities, not Models

Render dynamic content via a Content Renderer Map

2.2 Domain Layer

Entities: Core business objects (Exam, Module, Question, Content, Payment)

Repositories: Abstract contracts for data sources

Use Cases: Encapsulate business logic

Example:

class FetchExamsUseCase {
  final ExamRepository repository;
  FetchExamsUseCase(this.repository);

  Future<List<Exam>> call({String? filter}) {
    return repository.getExams(filter: filter);
  }
}


Rules:

No knowledge of API or database

Only work with Entities

Composable & testable

2.3 Data Layer

Models: Freezed-based, JSON serialization

Repositories Implementation: Implement Domain Repositories

Data Sources:

Remote (API via Dio + MainService)

Local (SecureStorage, SharedPreferences, Hive/SQLite if needed)

Mapping: Model ↔ Entity

Example:

class ExamRepositoryImpl implements ExamRepository {
  final ExamRemoteDataSource remote;
  final ExamLocalDataSource local;

  Future<List<Exam>> getExams({String? filter}) async {
    try {
      final response = await remote.fetchExams(filter: filter);
      final exams = response.map((e) => e.toEntity()).toList();
      await local.cacheExams(exams);
      return exams;
    } catch (e) {
      return await local.getCachedExams();
    }
  }
}

3️⃣ App Startup Flow

App Launch

Initialize SecureStorage

Initialize Dio / MainService

Load AppConfig from backend

Store AppConfig locally

Initialize Theme via AppThemeMapper

Check:

Maintenance mode → redirect to Maintenance screen

Force update → redirect to PlayStore / AppStore

Load Authentication state

Navigate:

Authenticated → Home (Exams / Modules)

Unauthenticated → Login / Signup

Pre-fetch:

Cached exams & modules

User subscription status

Ads config

4️⃣ Feature Workflows
4.1 Auth Workflow

Login / Signup

Token Storage: SecureStorage

Refresh Token: Dio interceptor

Multiple Login Detection: Future-ready via backend flag

BLoC Flow: AuthBloc → LoginEvent → LoginUseCase → AuthRepository → API

Error Handling: API errors mapped to user-friendly states

4.2 AppConfig & Theme Workflow

Backend sends:

Theme: "PRIMARY_BLUE"

Maintenance Mode: true/false

Force Update: true/false

App maps theme string → AppThemeType → AppTheme

All widgets use centralized theme constants (no inline colors)

4.3 Exam List Workflow

Fetch Exams: Use FetchExamsUseCase

Pagination enabled

Cached in SharedPreferences

UI subscribes to ExamBloc → emits:

Loading

Loaded(List<Exam>)

Error

Dynamic rendering:

Exam card layout based on backend config

4.4 Module List Workflow

Backend returns:

Modules for each exam

Module type (Free / Paid)

Unlock status

ModuleBloc handles:

Pagination

Subscription / unlock check

Offline cache (optional)

UI shows:

Locked modules → payment CTA

Unlocked modules → tap to open content

4.5 Content Engine Workflow

Backend sends ContentType and JSON payload

Dynamic mapping in Flutter:

Map<ContentType, Widget Function(ContentEntity)> contentRenderer = {
  ContentType.video: (c) => VideoPlayerWidget(c),
  ContentType.pdf: (c) => PdfViewerWidget(c),
  ContentType.practiceSet: (c) => PracticeSetWidget(c),
};


UI only calls ContentRenderer.render(contentEntity)

Adding new content type → only update rendererMap (no UI rewrite)

4.6 Mock Test Engine

BLoC: MockTestBloc

State:

questions

answers

timeRemaining

submissionStatus

Timer: Independent from rebuilds, using Ticker or CountdownTimer

Features:

Auto submit on timeout

Offline answer saving

Prevent back navigation abuse

Sync final submission with API

Caching: Answers cached in local storage (SharedPreferences / Hive)

4.7 Payment Workflow

Razorpay integration

Flow:

PaymentBloc → Create order via backend

Open Razorpay checkout

On success → verify backend

Unlock module after verification

BLoC manages:

isProcessing

paymentStatus

errorMessage

4.8 Ads / Reward Workflow

Fetch ads config from backend

Render in dynamic slots

Handle rewarded ads / interstitials

Dynamic mapping → no hardcoded widget positions

5️⃣ Network & API Architecture

Centralized MainService

Dio with interceptors

Authorization header injection

Refresh token handling

Error mapping to ApiResponse<T>

All APIs defined in api_endpoints.dart

Caching Strategy:

Exams, Modules → SharedPreferences / Hive

Mock Test questions → optional local cache

Pagination built-in for list APIs

6️⃣ Security Strategy

Tokens → SecureStorage

401 → refresh token interceptor

Sensitive data → not stored in local storage

Prevent screenshot in mock test

Backend-controlled multiple login detection

Future-ready device binding (optional)

7️⃣ Performance Optimization

const constructors everywhere

Equatable / Freezed for state equality → avoid rebuild storms

Pagination & lazy loading

Cached API responses for offline use

Heavy widgets (PDF / Video) loaded on demand

Modular BLoC → prevents unnecessary rebuilds

8️⃣ Extensibility & Configuration

New content type → only update rendererMap

Backend can add:

PRACTICE_SET

VIDEO

PDF

QUIZ

No code rewrite needed

Dynamic mapping for:

Theme

Exams

Modules

Content

Ads

Payments

9️⃣ Full Data Flow Diagram (Simplified)
[Backend API] → [MainService/Dio] → [RepositoryImpl]
          ↘                           ↘
         Cache/LocalStorage           Domain Entity
                                    ↘
                                  UseCase
                                    ↘
                                   BLoC
                                    ↘
                                  UI Widgets


All arrows follow clean architecture rules

UI → BLoC → UseCase → Repository → DataSource → API

Data flows back as Entities

Caching happens inside repository/data source

🔟 Summary Checklist
Feature	Meets Principle?
Dynamic Exams/Modules	✅
Content Engine (dynamic renderer)	✅
Mock Test Engine (timer, offline, anti-cheat)	✅
Payments (Razorpay + verification)	✅
Ads (dynamic slots)	✅
Theme System (backend-driven)	✅
Caching & Offline	✅
Security (tokens, screenshot, refresh)	✅
Clean Architecture	✅
Extensibility (new content types)	✅
Scalability (100k+ users)	✅
State Management (BLoC, immutable)	✅
Network Layer (MainService + Dio + interceptors)	✅

✅ Conclusion

This workflow meets all your original architecture goals.

Fully production-ready, cleanly layered, backend-driven, dynamic, secure, and extensible.

Supports scaling to large user base and future feature additions without rewriting core logic.