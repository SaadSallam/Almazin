# Almazin App — Project Map

## [TECH_STACK]

| Layer | Technology | Version | Status |
|-------|-----------|---------|--------|
| Framework | Flutter | 3.41.9 (stable) | ✅ |
| Language | Dart | 3.11.5 (stable) | ✅ |
| State | flutter_bloc | ^9.1.1 (locked 9.2.1) | ✅ |
| Equality | equatable | ^2.0.8 | ✅ |
| Storage | hive + hive_flutter | ^2.2.3 / ^1.1.0 | ✅ |
| IDs | uuid | ^4.5.3 | ✅ |
| Formatting | intl | ^0.20.2 | ✅ |
| Routing | go_router | ^17.2.3 | ✅ |
| Lints | flutter_lints | ^6.0.0 | ✅ |
| Icons | cupertino_icons | ^1.0.8 | ✅ |

**Date checked**: 2026-05 — all direct dependencies at latest resolvable versions.

## [SYSTEM_FLOW]

```
┌──────────────────────────────────────────────────────────────┐
│                    AppShell (RTL shell)                       │
│  ┌──────────┐  ┌──────────────────────────────────────────┐  │
│  │ Sidebar  │  │              DashboardPage                │  │
│  │ (nav)    │  │  ┌────────────────────────────────────┐  │  │
│  │          │  │  │  Feature Pages (scrollable body)    │  │  │
│  │  • أسعار │  │  │                                    │  │  │
│  │    البن   │  │  │  CoffeePricesPage                  │  │  │
│  │  • العملاء│  │  │    ├─ CoffeeTypeCard list          │  │  │
│  │  • حاسبة  │  │  │    └─ CoffeeTypeEditorDialog       │  │  │
│  │    التوليفة│  │  │                                    │  │  │
│  │  • الإعدادات│ │  │  CustomersPage                     │  │  │
│  │          │  │  │    ├─ CustomerCard list             │  │  │
│  │          │  │  │    ├─ CustomerEditorDialog          │  │  │
│  │          │  │  │    └─ CustomerDetailPage            │  │  │
│  │          │  │  │        ├─ Profile section           │  │  │
│  │          │  │  │        ├─ Blend section             │  │  │
│  │          │  │  │        └─ Weight calculator         │  │  │
│  │          │  │  │                                    │  │  │
│  │          │  │  │  CalculatorPage                     │  │  │
│  │          │  │  │    ├─ CalculatorLineRow list        │  │  │
│  │          │  │  │    ├─ CalculatorSummaryCard         │  │  │
│  │          │  │  │    └─ SavePercentageBlendDialog     │  │  │
│  │          │  │  │                                    │  │  │
│  │          │  │  │  SettingsPage (theme toggle)        │  │  │
│  │          │  │  └────────────────────────────────────┘  │  │
│  └──────────┘  └──────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

**User journeys**:
1. **Coffee Prices**: Browse → Add/Edit coffee type (name, price/kg, notes) → Persisted in Hive
2. **Customers**: Browse → Add/Edit customer profile → Create percentage blend → Calculate weight from blend
3. **Calculator**: Select coffees → Enter grams per coffee → See cost/weight summary → Save as percentage blend
4. **Settings**: Toggle light/dark theme

## [ARCHITECTURE]

```
lib/
├── main.dart                          # Entry point, init storage + logger
├── app/                               # App shell + routing
│   ├── almazin_app.dart               # MaterialApp.router, theme, RTL
│   └── app_router.dart                # go_router ShellRoute + Bloc providers
├── core/                              # Shared infra (no feature logic)
│   ├── formatting/egp_format.dart     # EGP price formatting (intl)
│   ├── logging/app_logger.dart        # Async stream-based logger
│   ├── navigation/
│   │   ├── app_nav.dart               # AppNavItem definitions
│   │   └── app_paths.dart             # Route path constants
│   ├── responsive/
│   │   ├── app_breakpoints.dart       # mobile/tablet/desktop breakpoints
│   │   └── responsive_context.dart    # BuildContext extension
│   ├── storage/app_storage.dart       # Hive box init
│   └── theme/
│       ├── almazin_theme_tokens.dart  # Custom ThemeExtension tokens
│       ├── app_colors.dart            # Color primitives (light/dark)
│       ├── app_fonts.dart             # thmanyahsans family
│       ├── app_theme.dart             # ThemeData builders
│       └── theme_tokens_x.dart        # BuildContext extension
├── features/                          # Feature modules (DDD)
│   ├── calculator/                    # Blend calculator
│   │   ├── data/
│   │   │   └── customer_blend_drafts_datasource.dart
│   │   ├── domain/
│   │   │   ├── customer_percentage_blend_draft.dart
│   │   │   └── direct_weight_calculator_service.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       ├── formatting/
│   │       ├── widgets/
│   │       └── calculator_page.dart
│   ├── coffee_prices/                 # Coffee type CRUD
│   │   ├── data/ (model, datasource, repository impl)
│   │   ├── domain/ (entity, repository interface, validators)
│   │   └── presentation/ (page, cubit, widgets)
│   ├── customers/                     # Customer + blend management
│   │   ├── data/ (model, datasource, repository impl)
│   │   ├── domain/ (entity, repository, validators, services)
│   │   └── presentation/ (pages, cubits, widgets)
│   ├── settings/                      # App settings
│   │   └── presentation/settings_page.dart
│   └── theme/                         # Theme persistence
│       ├── data/theme_repository_impl.dart
│       ├── domain/ (preference, repository)
│       └── presentation/cubit/
├── shared/                            # Reusable UI components
│   ├── layout/app_shell.dart          # Shell with sidebar + top bar
│   └── widgets/ (button, card, dialog, search, section, sidebar, topbar, dashboard_page, responsive_container)
└── test/
    ├── widget_test.dart               # Smoke test: app builds
    └── percentage_blend_weight_calculator_test.dart  # Service + validator
```

### Data flow pattern
```
UI (Page) → Cubit → Repository → LocalDataSource → Hive Box
                  ↑
             Domain Service (pure Dart, no deps)
```

### Key architectural decisions
- **No DI framework** — manual constructor injection in `AppRouter.create()`
- **No code generation** — Hive used as `Box<dynamic>` (type-safe via manual serialization in models)
- **RTL-first** — `Directionality` wraps the entire app, all layout uses `start`/`end` alignment
- **Responsive shell** — 3 breakpoints: mobile (drawer), tablet (collapsible sidebar), desktop (always-open sidebar)

## [ORPHANS & PENDING]

| Item | Type | Status | Notes |
|------|------|--------|-------|
| `AppSearchField` in top bar | Code smell | ⚠️ Orphan | `onChanged: (_) {}` — no search implementation |
| `CustomerBlendDraftsDataSource` | Code smell | ⚠️ Underused | Only used in calculator save flow; drafts saved but not browsable |
| `PercentageBlendWeightCalculatorService` | Deprecated | ⚠️ Legacy | Replaced by `BlendCalculationService` — kept for backward compatibility |
| Test coverage | Gap | ⚠️ Low | 4 tests (1 widget smoke, 3 unit). No cubit tests, no datasource tests |
| Error reporting | Gap | ⏳ Future | No crash analytics or remote error tracking |
| Calculator → Customer link | Gap | ⏳ Future | Saved percentage blends from calculator don't attach to a customer |
| `dart:io` import in widget_test | Code smell | ⚠️ Minor | Should use `package:file` or directory-independent temp setup |

## Milestones (Verifiable Goals)

### M0 — Audit & Stability (current)
- [x] All dependencies at latest stable (2026-05)
- [x] 0 analysis issues (`flutter analyze` clean)
- [x] 4/4 tests pass
- [x] Async logging system deployed (`core/logging/app_logger.dart`)

### M1 — Quality Gates
- [ ] Add cubit tests for CoffeePricesCubit, CustomersListCubit
- [ ] Add datasource unit tests with in-memory Hive
- [ ] Resolve `AppSearchField` orphan or remove it

### M2 — Feature Completion
- [ ] Link calculator "حفظ كتوليفة عميل" to customer selection
- [ ] Implement search across customers list
- [ ] Browse/delete saved blend drafts

### M3 — Polish
- [ ] Add error boundary/widget for crash recovery
- [ ] Accessibility audit (semantics, screen reader)
- [ ] Performance profile (widget rebuilds, Hive latency)

### M4 — Customer Blend System (Completed ✅)
- [x] Created `BlendCalculationService` — reusable calculation engine
- [x] Updated `BlendComponent` to store `weightInGrams` (percentages computed)
- [x] Updated `CustomerModel` with backward-compatible migration (old % → new grams)
- [x] Updated `CustomerDetailCubit` for weight-based blend editing
- [x] Updated `CustomerBlendSection` UI with weight inputs, live percentages, costs
- [x] Updated `CustomerWeightCalculatorSection` with proportional scaling
- [x] Added `scaleToTargetWeight` for quick weight buttons (250g/500g/1kg)
- [x] All tests pass, zero analysis issues
