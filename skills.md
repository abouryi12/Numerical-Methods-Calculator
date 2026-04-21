# AGENTS.md — NumeriX Flutter Project

## Project Identity
- **App Name:** NumeriX
- **Type:** Flutter Mobile Application
- **Purpose:** Advanced Numerical Methods Calculator
- **Language:** Dart (Flutter)
- **Target:** Android & iOS, responsive (mobile + tablet)

---

## Architecture Rules

- Follow the exact folder structure:
```
lib/
├── core/precision/
├── core/validators/
├── methods/root_finding/
├── methods/linear_systems/
├── methods/iterative/
├── methods/interpolation/
├── models/
├── ui/screens/
├── ui/widgets/
└── ui/theme/
```
- **Never** put business logic inside UI files
- Every method lives in its own `.dart` file
- Models are immutable — use `final` fields only

---

## Naming Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables & functions: `camelCase`
- Constants: `kConstantName`
- Private fields: `_fieldName`

---

## Numerical Methods Rules

- Every method must return a `MethodResult` model, never raw values
- Every method must accept a `PrecisionSettings` parameter
- Apply `applyPrecision(value, settings)` on **every intermediate value** inside iteration loops — not only on the final result
- Every method must validate inputs **before** computing — throw `ValidationException` if invalid
- Max matrix size: 6×6

```dart
// ✅ Correct pattern
double xNew = applyPrecision(x - fx / dfx, settings);

// ❌ Wrong — precision only on final result
double root = bisection(f, a, b);
return applyPrecision(root, settings);
```

---

## Precision Utility

- Located at: `lib/core/precision/precision_utils.dart`
- Two modes only: `PrecisionMode.rounding` and `PrecisionMode.chopping`
- Signature must be:
```dart
double applyPrecision(double value, PrecisionSettings settings)
```
- **Never** inline precision logic inside method files — always call the utility

---

## Validation Rules

- Located at: `lib/core/validators/`
- One validator per method category (e.g., `root_finding_validator.dart`)
- Return type: `ValidationResult` with `isValid` bool + `errorMessage` String
- Validation happens **before** any computation begins
- Error messages must be human-readable (no technical jargon)

---

## Models

Three core models — never deviate from these:

```dart
// Input to any method
class MethodInput {
  final String? expression;        // f(x) as string
  final List<double>? initialValues;
  final double? tolerance;
  final int? maxIterations;
  final PrecisionSettings precision;
  final List<List<double>>? matrix;
  final List<DataPoint>? dataPoints;
}

// One row in the iteration table
class IterationStep {
  final int iteration;
  final Map<String, double> values; // column name → value
}

// Final output of any method
class MethodResult {
  final double? answer;
  final int iterations;
  final double? approximateError;
  final List<IterationStep> steps;
  final bool converged;
  final String? errorMessage;
}
```

---

## UI Rules

- **Dark theme only** — background `#0D0D0F`, surface `#1A1F3A`
- Accent blue: `#4A9EFF` — used for primary buttons and active states only
- Accent purple: `#7B6FF0` — used for Interpolation category only
- All theme values live in `lib/ui/theme/app_theme.dart` — **never hardcode colors**
- Font for math/code: `Roboto Mono`
- Font for UI labels: `Inter`
- Border radius: `12` for cards, `8` for inputs
- Base spacing unit: `16.0`

---

## Math Input & Rendering

- Parser package: `math_expressions`
- Renderer package: `flutter_math_fork`
- Live preview must update on every keystroke — use `onChange` not `onSubmitted`
- Always show a preview pane below the input field
- If rendering fails → fallback to plain `Text` widget, never crash

---

## Error Handling

- Validation errors → shown **inline** under the input field using `errorText`
- **Never** use `showDialog` or `SnackBar` for validation errors
- Use `SnackBar` only for system-level messages (e.g., copy to clipboard success)
- Computation errors → shown in the results section with red color `#EF4444`
- Empty states must always be handled — never show a blank screen

---

## State Management

- Use **Riverpod** — no `setState` outside simple local UI state
- One `StateNotifier` per method category
- State shape per notifier:
```dart
class SolverState {
  final MethodInput? input;
  final MethodResult? result;
  final bool isLoading;
  final String? validationError;
}
```
- Global precision settings in a single `precisionProvider`

---

## Performance Rules

- All numerical computations must run in an `Isolate` — never on the UI thread
- Matrix operations: limit to 6×6 max
- Iteration tables: render lazily if steps > 50

---

## What NOT To Do

- ❌ Don't use `setState` for solver state — use Riverpod
- ❌ Don't hardcode any color, spacing, or font value in widgets
- ❌ Don't apply precision only at the end of a method — apply inside loops
- ❌ Don't use `print()` — use proper logging or remove before commit
- ❌ Don't show dialogs for validation errors — inline only
- ❌ Don't create god classes — one responsibility per file
- ❌ Don't skip the `ValidationResult` check before calling any method

---

## Packages (pubspec.yaml)

```yaml
dependencies:
  flutter_riverpod: ^2.x
  math_expressions: ^2.x
  flutter_math_fork: ^0.x
  google_fonts: ^6.x
  fl_chart: ^0.x         # bonus — graph plotting
```

---
  # NumeriX — Frontend & Visual Design Specification
 Design Philosophy
The interface is a precision tool, not a product page. Every element earns its place. Nothing decorates. Nothing announces itself. The user opens the app with a problem — the interface gets out of the way and lets them solve it.
Three rules that govern every decision:

If it doesn't serve the computation, it doesn't exist
Spacing is not decoration — it is structure
Dark means depth, not black paint


Color System
dart// Background layers — never use flat black
kBgBase      = #0A0A0C   // deepest layer — app background
kBgSurface   = #111116   // cards, panels
kBgElevated  = #18181F   // inputs, matrix cells, dropdowns
kBgBorder    = #232329   // dividers, cell borders, outlines

// Text
kTextPrimary   = #F0F0F5  // headings, values, answers
kTextSecondary = #6B6B80  // labels, descriptions, metadata
kTextMuted     = #3A3A48  // placeholders, disabled

// Accent — used sparingly, never decoratively
kAccentBlue    = #4A8FE8  // primary action only (SOLVE button, active state)
kAccentPurple  = #7B6FF0  // interpolation category only

// Semantic
kSuccess  = #2D6A4F  // dark green — converged state
kError    = #7F1D1D  // dark red — validation error background
kErrorText = #FCA5A5 // light red — error message text
kWarning  = #78350F  // dark amber — max iterations reached
Rules:

kAccentBlue appears once per screen maximum — on the primary action
Never use opacity on accent colors to create variants — use the defined tokens only
Gradients: forbidden except one — the subtle kBgBase → kBgSurface on the home screen category cards, linear, vertical, 0% to 100% opacity, max 60px height


Typography
dart// UI Font — all labels, navigation, descriptions
Inter

// Math Font — expressions, results, iteration tables, matrix cells
Roboto Mono

// Scale
kTextXS   = 11px  // metadata, table headers
kTextSM   = 13px  // secondary labels, descriptions
kTextBase = 15px  // body, inputs, list items
kTextLG   = 18px  // section titles, method names
kTextXL   = 24px  // screen titles
kText2XL  = 32px  // final answer display
kText3XL  = 48px  // home screen app name only
Rules:

Font weight: 400 for body, 500 for labels, 600 for titles — never 700 or bold except the app name
Letter spacing: 0 for body, 0.01em for uppercase labels, -0.02em for large display text
Line height: 1.5 for body, 1.2 for display
Math expressions always in Roboto Mono — never in Inter
Never mix weights in the same line


Spacing & Layout
dart// Base unit: 4px
kSpace1  = 4px
kSpace2  = 8px
kSpace3  = 12px
kSpace4  = 16px
kSpace5  = 20px
kSpace6  = 24px
kSpace8  = 32px
kSpace10 = 40px
kSpace12 = 48px
kSpace16 = 64px
Rules:

All spacing is a multiple of 4 — no exceptions
Screen horizontal padding: kSpace5 (20px) on mobile, kSpace8 (32px) on tablet
Section gap (between major sections): kSpace8 minimum
Element gap (between related items): kSpace3 or kSpace4
Never use kSpace1 (4px) as a standalone gap — only as internal padding


Border Radius
dartkRadiusXS = 4px   // tags, badges, small chips
kRadiusSM = 6px   // inputs, matrix cells, buttons
kRadiusMD = 10px  // cards, panels, modals
kRadiusLG = 14px  // category cards on home screen
Rules:

Never use BorderRadius.circular(50) — pill shapes are forbidden
Never use 0 radius on interactive elements
Consistency: all inputs on the same screen use the same radius


Elevation & Depth
No box shadows. No blur effects. No frosted glass.
Depth is created through background color layering only:
kBgBase (deepest)
  └── kBgSurface (cards float here)
        └── kBgElevated (inputs sit here)
              └── kBgBorder (outlines define edges)
The only permitted border: 1px solid kBgBorder on cards and inputs. Never thicker. Never colored (except error state: 1px solid #7F1D1D).

Screens
Home Screen

App name NumeriX top-left, kText2XL, Inter 600, kTextPrimary
Settings icon top-right — 20px, kTextSecondary, no background
Three category cards stacked vertically, full width
Each card:

Background: kBgSurface
Border: 1px solid kBgBorder
Border radius: kRadiusLG
Padding: kSpace5 vertical, kSpace5 horizontal
Left edge accent: 3px wide, kRadiusXS, color per category
Category name: kTextLG, Inter 500, kTextPrimary
Method count: kTextSM, Roboto Mono, kTextSecondary — e.g. 4 methods
Icon: 24px, monochrome, kTextSecondary
No chevron, no arrow — the whole card is tappable




Method Selection Screen

Back button top-left — text only, no icon, kTextSecondary
Category name as page title — kTextXL, Inter 600
Methods as a flat list — no grid
Each method item:

Background: transparent by default
Border bottom: 1px solid kBgBorder — acts as divider
Padding: kSpace4 vertical
Method name: kTextBase, Inter 500, kTextPrimary
Description: kTextSM, Inter 400, kTextSecondary
Selected state: background kBgSurface, left border 3px solid kAccentBlue, no animation — instant


No "Continue" button — tapping a method navigates directly


Solver Screen
Header

Back arrow left, method name center — kTextBase, Inter 500
No extra icons or actions in header

Math Input Zone

Label: FUNCTION — kTextXS, Inter 500, kTextSecondary, letter-spacing 0.08em
Input field:

Background: kBgElevated
Border: 1px solid kBgBorder
Border radius: kRadiusSM
Font: Roboto Mono, kTextBase, kTextPrimary
Padding: kSpace3 vertical, kSpace4 horizontal
Cursor color: kAccentBlue
Focused border: 1px solid #2A2A38 — barely visible change, no glow


Preview pane (below input):

Background: kBgBase
Border: 1px solid kBgBorder
Border radius: kRadiusSM
Padding: kSpace3
Rendered math in flutter_math_fork — kTextLG, kTextPrimary
Label above: PREVIEW — same style as FUNCTION label
If expression is invalid: show — in kTextMuted, no error here



Parameters Section

Label: PARAMETERS — same label style
Inputs in a 2-column grid for [a, b] or x₀, x₁
Tolerance and max iterations full width, stacked
All inputs same style as function input field
Placeholder text: kTextMuted, Roboto Mono

Precision Panel

Label: PRECISION — same label style
Two-segment control: ROUNDING / CHOPPING

Container: kBgElevated, kRadiusSM, 1px solid kBgBorder
Active segment: kBgSurface, 1px solid kBgBorder — no color fill
Text: kTextXS, Inter 500, letter-spacing 0.06em


Digit selector: horizontal row of numbers 1 through 10

Each digit: 32px × 32px, kRadiusXS
Default: transparent background, kTextSecondary
Selected: kBgElevated, kTextPrimary, 1px solid kBgBorder



SOLVE Button

Full width
Background: kAccentBlue
Border radius: kRadiusSM
Height: 48px
Text: SOLVE, Inter 600, kTextXS size scaled to 14px, letter-spacing 0.1em, white
No shadow, no glow
Loading state: text replaced with 3px circular progress indicator, white, centered
Disabled state: kBgElevated background, kTextMuted text — same size, no opacity trick

Results Section

Appears below the button after solving — no modal, no navigation
Separator: 1px solid kBgBorder, full width, kSpace6 margin top/bottom
Answer label: RESULT — same label style
Answer value: kText2XL, Roboto Mono, kTextPrimary
Stats row (iterations + error): inline, kTextSM, Roboto Mono, kTextSecondary

Format: 12 iterations  ·  ε = 0.000043


Converged badge: CONVERGED or MAX ITERATIONS — kTextXS, Inter 500, letter-spacing 0.08em

Converged: kSuccess background, light green text
Max iterations: kWarning background, light amber text
Padding: kSpace1 vertical, kSpace2 horizontal, kRadiusXS




Matrix Input Screen

Grid renders as a table — Roboto Mono throughout
Each cell:

Size: equal width, calculated from screen width ÷ columns
Background: kBgElevated
Border: 1px solid kBgBorder
Border radius: 0 — cells are flush with each other
Focused cell border: 1px solid #2A2A38
Text: centered, kTextBase, kTextPrimary


Size picker: plain text buttons 2×2 3×3 4×4 5×5 6×6

Active: kTextPrimary, Inter 500
Inactive: kTextMuted, Inter 400
No background, no border — just the text




Settings Screen

Plain list — no cards, no sections with heavy headers
Each setting row: label left, control right, 1px solid kBgBorder bottom border
Section label: kTextXS, Inter 500, kTextSecondary, letter-spacing 0.08em, kSpace6 margin top
Toggle (precision mode): same segment control as solver screen
About section at bottom: kTextSM, kTextMuted, centered


Interaction & Motion

Tap feedback: InkWell with splashColor: transparent, highlightColor: kBgBorder at 30% opacity — subtle, not flashy
Screen transitions: default Flutter push — no custom animation
Results appearance: no animation — results render instantly in place
No bouncing, no spring physics, no hero animations
Keyboard: dismiss on tap outside any input — always


Error States

Inline only — directly under the relevant input field
Text: kTextSM, Inter 400, kErrorText
No icon, no background, no border change on the field itself
Format: plain sentence — "Root is not bracketed in [a, b]"
Disappears the moment the user starts editing


Empty States

Solver screen before solving: results section hidden entirely — not empty, not placeholder
Method list: never empty (always has methods)
Matrix: pre-filled with 0.0 in all cells on load


Responsive Behavior

Mobile (< 600px): single column, full-width everything
Tablet (≥ 600px): solver screen splits into two columns — inputs left, results right — 50/50
No horizontal scroll anywhere
Minimum tap target: 44px on all interactive elements


What This Design Is Not

No blur, no frosted glass, no BackdropFilter
No gradient buttons
No colored shadows or glows
No icon inside the SOLVE button
No bottom sheets for settings or options — navigate to a screen
No tooltip, no long-press menu
No animation on the precision panel toggle
No skeleton loaders — computation is fast enough for a simple spinner
#