# Core Development Standards

## 🧠 Reasoning Process
- **Analyze First:** Before providing code, scan the existing codebase to identify architectural patterns and naming conventions.
- **Context Awareness:** Ensure all suggestions are compatible with the project's current dependencies and versions.
- **Step-by-Step:** For complex refactoring, outline the plan before writing code.

## 🛠 Programming Principles
- **DRY (Don't Repeat Yourself):** Extract reusable logic, but avoid premature abstraction that leads to unnecessary complexity.
- **KISS (Keep It Simple, Stupid):** Write code for humans first, machines second. Avoid "clever" one-liners if they hurt readability.
- **SOLID:** Adhere to Single Responsibility and Open/Closed principles.
- **Consistency:** Match the project's existing indentation, casing (camelCase, snake_case), and file organization.

## 🧪 Quality & Safety
- **Defensive Programming:** Anticipate edge cases and handle nulls/errors gracefully.
- **Documentation:** Add concise comments for non-obvious logic.
- **Performance:** Avoid O(n²) operations where O(n log n) or O(n) is possible.

## 💬 Communication Style
- Be concise and technical.
- When proposing a breaking change, explicitly warn the user.
- Always specify the file path before the code block.

## 🧱 Flutter & Dart Specifics
- **Field Declaration Order:** Always declare `final` fields before the constructor. The constructor must come after all field declarations, never before.
- **Standalone Widgets Only:** Every UI component must be its own dedicated widget class in its own file. Strictly forbidden: private widget classes in the same file (e.g. `class _MyWidget`), helper methods returning a `Widget` (e.g. `_buildHeader()`), and private instance methods or getters on widget classes that compute display values (e.g. `String _buildDateLabel()`, `int get _paidCents`).
- **No Passthrough Wrappers:** Never create a widget class whose sole purpose is to pass data to child widgets (e.g., `ActivityDetailsView` that just rebuilds what the screen already renders). Put the content directly in the screen's `build` method instead.
- **Global Shared Extensions:** Favor global shared extensions (e.g., on `String`, `DateTime`, `num`) stored in a centralized directory instead of local utility functions or private extensions.
- **Presentation-Layer Extensions:** UI-specific logic that does not belong in the shared domain (e.g. relative date labels, entity projections for display) must be placed in dedicated extension files under `<feature>/presentation/extensions/`. Never put this logic in private methods on widget classes.
- **Function Body Preference:** Prefer explicit block bodies `() { ... }` over arrow syntax `() => ...` for functions and methods to maintain consistency and allow for easier future expansion. **Exceptions** (use arrow when the whole expression fits comfortably on a single line):
- Short single-expression predicates passed to Bloc APIs: `buildWhen`, `listenWhen`, `whereType`, `where`.
- Short single-expression callbacks on `StatefulWidget` / `State` lifecycle hooks (e.g. one-line `shouldRepaint`, `shouldRebuild`, overrides that just delegate).
- Short static helpers / getters that return a single expression (e.g. URL builders in `Endpoints`, computed entity getters).
Multi-statement bodies, async logic, or anything that wouldn't fit on one line stay in block form.
- **Double Quotes:** Always use double quotes for strings. Switch to single quotes only when the string itself contains a double quote, to avoid unnecessary escaping (e.g. use `"L'architecture"` instead of `'L\'architecture'`).
- **State Management with Bloc:** Never call `setState` in widgets. All reactive UI state (form drafts, selections, toggles, etc.) must live in the feature's `Bloc` / `Cubit` and be consumed via `BlocBuilder`, `BlocSelector` or `BlocListener` with a precise `buildWhen` / `listenWhen`. `StatefulWidget` is allowed only to manage non-state resources requiring lifecycle hooks (`TextEditingController`, `AnimationController`, `FocusNode`, etc.) — `setState` calls remain forbidden.
