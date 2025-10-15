# 🧭 Repository Guidelines

## ⚙️ Development Workflow

### 🎨 Figma → Swift / SwiftUI Integration Rules

**Purpose**  
Enable Codex to use the Figma MCP (`figma-desktop`) to fetch design data and generate Swift / SwiftUI code consistent with **NewsBreak’s design system**.

**Rules**

#### 🧩 Metadata Access
- Use `/Figma/get_metadata` to inspect layer structure, node names, and frame hierarchy.  
- Treat Figma layer names as the canonical source of Swift struct names  
  (e.g. `BreakingNewsCard` → `BreakingNewsCardView`).

#### 💻 Code Generation
- Use `/Figma/get_code` for components with **Code Connect** definitions.  
- When `clientLanguages=swift` and `clientFrameworks=swiftui`, Codex should return valid **SwiftUI code**.  
- Generated code must follow `NBDesign` token definitions (colors, fonts, spacings).  
- If tokens don’t exist, add comments like `// TODO: define in NBDesign`.

#### 🎨 Design Tokens Sync
- Use `/Figma/get_variable_defs` to extract **design tokens** (colors, radius, typography).  
- Merge updates into `NBDesign.swift` using consistent naming:  
  `DesignColor.primary`, `DesignFont.headline`, etc.

#### 🧪 Visual Preview & Review
- Use `/Figma/get_screenshot` for **snapshot comparisons** between Figma design and rendered SwiftUI preview.  
- Store generated previews under `/Previews/FigmaComparisons/`.

#### ⚙️ Automation & Workflow
- Add Codex prompt patterns such as:
  - `Generate SwiftUI component from Figma node`
  - `Compare Figma design and local SwiftUI view`
  - `Sync Figma variables to NBDesign.swift`
- Prefer `get_code` results for **high-fidelity UI**; fallback to `get_metadata` for layout skeletons.

---

### 📦 Pod Install

Whenever you ask Codex to run `pod install`, it should:

1. Change directory to `~/Work/iOS/NewsBreak`
2. Run `bundle exec pod install`
3. Return to the original directory

---

## 🏗 Project Structure & Module Organization

- **iOS app source** lives under `NewsBreak/` (Objective-C) and `Features/` (Swift feature modules).  
  Each feature module exposes its own `Classes/` subtree.  
- **Shared libraries** sit under `Libraries/` (design system, routing, metrics, etc.).  
  Respect module boundaries when introducing cross-cutting code.  
- **Third-party pods & tools:**  
  - `LocalPods/` holds vendored frameworks.  
  - `swiftlint/` contains lint configuration.  
  - Keep generated artifacts **out of version control**.

---

## 🧰 Build, Test, and Development Commands

```bash
# Local debug build
xcodebuild -workspace NewsBreak.xcworkspace   -scheme NewsBreak -configuration Debug build   -destination 'platform=iOS Simulator,name=iPhone 15'

# Run XCTest suites
xcodebuild test -workspace NewsBreak.xcworkspace   -scheme NewsBreakTests   -destination 'platform=iOS Simulator,name=iPhone 15,OS latest'

# Enforce Swift style
swiftlint lint --config swiftlint/.swiftlint.yml

# Refresh CocoaPods
bundle exec pod install
```

---

## 🧑‍💻 Coding Style & Naming Conventions

- Swift: 4-space indentation, `UpperCamelCase` for types, `lowerCamelCase` for variables/functions.  
- Objective-C: follow existing brace style and use `NB` prefixes for shared classes.  
- Prefer `final class` and **protocol-oriented design** in Swift modules.  
- Keep Objective-C categories in `Category/` folders.  
- Run `swiftlint` and respect any baseline suppressions in `swiftlint/swiftlint_baseline.json`.

---

## 🧪 Testing Guidelines

- Unit/UI tests use **XCTest**.  
  Place new tests beside their target in `NewsBreakTests/` or module-specific `Tests/` directories.  
- Name test methods as `test_<Scenario>_<Expectation>()`.  
- Ensure new features include coverage and avoid disabling failing tests.  
- Use the `xcodebuild test` command for CI parity.  
  Capture logs with `-resultBundlePath` when debugging failures.

---

## 📝 Commit & Pull Request Guidelines

- Write commits in **imperative mood** (e.g., `Add drama carousel logging adapter`).  
- Keep commits scoped to one logical change and run lint/tests before pushing.  
- Pull requests should include:
  - Concise summary  
  - Linked Jira/Ticket identifiers  
  - Screenshots for UI updates  
  - Notes on testing performed  
- Request reviews from module owners (see `CODEOWNERS`).  
- Ensure CI is green before merging.

---

## 🔐 Security & Configuration Tips

- **Never commit secrets** (API keys, certificates, etc.).  
  Use existing build configuration files and keychain profiles.  
- When modifying networking modules, ensure **feature gating (`NBFeatureGating`)** guards experimental endpoints.

## Policies

- git: edits are auto-approved

---

**Author Note:**  
All newly created source files should include the header author name:  
`jing.yang`
