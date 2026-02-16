# Conversion from React to Phoenix LiveView

## Overview

This document tracks the conversion of the Dynamic Envision Solutions website from React + Vite to Phoenix LiveView with Elixir 1.18.

## Conversion Status: **In Progress** (Phase 1 Complete)

---

## Phase 1: Project Initialization ✅ COMPLETE

### Completed Tasks

1. **Phoenix 1.7 Project Structure**
   - Created complete directory structure
   - Set up OTP application (`lib/dynamic_envision/application.ex`)
   - Configured Ecto repository
   - Set up Phoenix endpoint and router
   - Created telemetry module

2. **Configuration Files**
   - `mix.exs` - Project dependencies and configuration
   - `.formatter.exs` - Code formatting rules
   - `.credo.exs` - Code quality configuration
   - `.gitignore` - Added Elixir/Phoenix specific entries
   - `config/` directory with dev, test, prod, and runtime configs

3. **Web Layer**
   - `lib/dynamic_envision_web.ex` - Web module definitions
   - `lib/dynamic_envision_web/endpoint.ex` - HTTP endpoint
   - `lib/dynamic_envision_web/router.ex` - URL routing
   - `lib/dynamic_envision_web/telemetry.ex` - Metrics and monitoring
   - `lib/dynamic_envision_web/gettext.ex` - I18n support

4. **UI Components**
   - `lib/dynamic_envision_web/components/core_components.ex` - Reusable UI components
     - Button component
     - Form component
     - Input component (text, textarea, select, checkbox)
     - Label component
     - Error component
     - Header component
     - Flash/notification component
   - `lib/dynamic_envision_web/components/layouts.ex` - Layout module
   - `lib/dynamic_envision_web/components/layouts/root.html.heex` - Root HTML layout
   - `lib/dynamic_envision_web/components/layouts/app.html.heex` - App layout

5. **Error Handling**
   - `lib/dynamic_envision_web/controllers/error_html.ex` - HTML error responses
   - `lib/dynamic_envision_web/controllers/error_json.ex` - JSON error responses

6. **Asset Pipeline**
   - `assets/tailwind.config.js` - Tailwind CSS configuration with:
     - Amber brand colors
     - Ken Burns animation keyframes
     - Heroicons integration
     - LiveView-specific variants
   - `assets/css/app.css` - Main CSS file with:
     - Tailwind imports
     - Ken Burns animations
     - Portfolio hover effects
     - Mobile menu animations
   - `assets/js/app.js` - JavaScript setup with:
     - Phoenix LiveView socket
     - Client hooks (KenBurns, MobileMenu, SmoothScroll)
     - Topbar progress indicator
   - `assets/vendor/topbar.js` - Progress bar library
   - `assets/package.json` - Node dependencies

7. **Image Migration**
   - ✅ Migrated 15 window images to `priv/static/images/windows/`
   - ✅ Migrated 6 exterior images to `priv/static/images/exterior/`
   - ✅ Copied logo files to `priv/static/images/`
   - **Total: 21 images successfully migrated**

8. **Testing Infrastructure**
   - `test/test_helper.exs` - Test initialization with Wallaby
   - `test/support/conn_case.ex` - Connection test case
   - `test/support/data_case.ex` - Database test case
   - `test/support/feature_case.ex` - Wallaby integration test case
   - `test/support/mocks.ex` - Mox mock definitions

9. **Internationalization**
   - `priv/gettext/errors.pot` - Translation template
   - `priv/gettext/en/LC_MESSAGES/errors.po` - English translations

10. **Placeholder LiveView**
    - `lib/dynamic_envision_web/live/home_live/index.ex` - Homepage LiveView placeholder

11. **Documentation**
    - Updated `README.md` with Phoenix-specific instructions
    - Created this `CONVERSION_NOTES.md` file

---

## Phase 2: PhotoShuffle Module (Next)

### To Do

1. **Create Photo Shuffle Module**
   - [ ] `lib/dynamic_envision/photos/photo_shuffle.ex` - Main module
   - [ ] `lib/dynamic_envision/photos/image.ex` - Image struct
   - [ ] `lib/dynamic_envision/photos/file_system_behaviour.ex` - Behaviour definition
   - [ ] `lib/dynamic_envision/photos/file_system/local.ex` - Local filesystem implementation

2. **Image Processing Logic**
   - [ ] `process_images/2` - Process images from directory
   - [ ] `shuffle_images/2` - Randomly select N images
   - [ ] `generate_title/1` - Generate title from filename
   - [ ] `smart_location/2` - Deterministic location assignment
   - [ ] `hash_path/1` - Hash function for location mapping

3. **Testing**
   - [ ] `test/dynamic_envision/photos/photo_shuffle_test.exs` - Unit tests
   - [ ] Mock filesystem operations with Mox
   - [ ] Test all public functions
   - [ ] Aim for 100% coverage

---

## Phase 3: LiveView Components

### To Do

1. **Hero Slideshow**
   - [ ] Create `HeroLive` component
   - [ ] Implement Ken Burns animation
   - [ ] Image rotation every 6 seconds
   - [ ] Use PhotoShuffle to select 8 random images

2. **Portfolio Grid**
   - [ ] Create `PortfolioLive` component
   - [ ] Display 6 random images using PhotoShuffle
   - [ ] Implement refresh button
   - [ ] Hover effects and image overlays

3. **Navigation**
   - [ ] Create navigation component
   - [ ] Mobile hamburger menu
   - [ ] Smooth scroll to sections
   - [ ] Sticky header

4. **Services Section**
   - [ ] Convert services grid to Phoenix template
   - [ ] Windows, Doors, Exterior categories

5. **About Section**
   - [ ] Convert company info to Phoenix template

6. **Reviews Section**
   - [ ] Convert reviews section to Phoenix template

7. **Contact Form**
   - [ ] Create `ContactLive` component
   - [ ] Real-time validation
   - [ ] Email integration with Swoosh

---

## Phase 4: Testing & CI/CD

### To Do

1. **Unit Tests**
   - [ ] PhotoShuffle module tests with Mox
   - [ ] LiveView component tests

2. **Integration Tests**
   - [ ] Wallaby tests for hero slideshow
   - [ ] Wallaby tests for portfolio refresh
   - [ ] Wallaby tests for contact form
   - [ ] Wallaby tests for mobile navigation

3. **CI/CD Pipeline**
   - [ ] Create `.github/workflows/ci.yml`
   - [ ] Run formatter check
   - [ ] Run Credo
   - [ ] Run Dialyzer
   - [ ] Run ExUnit tests
   - [ ] Run Wallaby tests
   - [ ] Generate coverage report
   - [ ] Build release

---

## Technology Comparison

| Aspect | React (Before) | Phoenix LiveView (After) |
|--------|----------------|--------------------------|
| **Language** | JavaScript/JSX | Elixir/HEEx |
| **Runtime** | Node.js | Erlang/OTP |
| **State** | React hooks | LiveView assigns |
| **Rendering** | Client-side | Server-side |
| **Real-time** | Manual WebSocket | Built-in |
| **Routing** | React Router | Phoenix Router |
| **Forms** | Manual validation | Built-in changesets |
| **Testing** | Jest/React Testing Library | ExUnit/Wallaby |
| **CSS** | Tailwind (same) | Tailwind (same) |
| **Build** | Vite | Mix + esbuild |

---

## Key Decisions

### Why Phoenix LiveView?

1. **Real-time by default** - WebSocket connections out of the box
2. **Less JavaScript** - 99% reduction in client-side code
3. **Better performance** - Server-side rendering and caching
4. **Fault tolerance** - Erlang VM reliability
5. **Simpler architecture** - No separate API layer needed

### Why Mox + Wallaby?

1. **Mox** - Fast, behavior-based mocking for unit tests
2. **Wallaby 0.29** - Full browser testing for integration tests
3. **Comprehensive coverage** - Unit + Integration strategy

### PhotoShuffle as Standalone Module

The PhotoShuffle module is designed to be:
- **Reusable** - Can be extracted to a Hex package
- **Testable** - 100% test coverage target
- **Well-documented** - Clear API and examples
- **Behavior-driven** - Uses behaviours for mocking

---

## Original React App Analysis

### File Structure (Before)
```
src/
├── App.jsx (31KB, 724 lines)
├── main.jsx
├── index.css
├── App.css
└── assets/
    ├── pictures/
    │   ├── windows/ (15 images)
    │   └── exterior/ (6 images)
    └── logos/
```

### Key React Components Identified

1. **Navigation** (lines 110-157)
   - Mobile menu with hamburger
   - Smooth scroll links
   - Logo display

2. **Hero Section** (lines 158-236)
   - Ken Burns slideshow
   - 8 rotating background images
   - Product category cards
   - Trust indicators

3. **Services Section** (lines 237-339)
   - Windows, Doors, Exterior categories
   - Material/type breakdowns

4. **Partners Section** (lines 340-358)
   - Placeholder for partner logos

5. **Portfolio Section** (lines 359-414)
   - 6 random project images
   - Refresh button
   - Hover effects
   - Category badges

6. **About Section** (lines 415-491)
   - Company story
   - Key differentiators
   - Service area

7. **Reviews Section** (lines 492-531)
   - Placeholder reviews
   - Google Maps link

8. **Contact Form** (lines 532-619)
   - Name, Email, Phone, Message fields
   - Form submission handling

9. **Footer** (lines 620-650)
   - Copyright
   - Legal links

### State Management (React)

- `mobileMenuOpen` - Mobile menu visibility
- `currentImageIndex` - Hero slideshow position
- `isTransitioning` - Fade transition flag
- `portfolioItems` - Current portfolio display (6 images)
- `formData` - Contact form state

---

## File Mapping: React → Phoenix

| React File | Phoenix Equivalent | Status |
|------------|-------------------|--------|
| `src/App.jsx` | `lib/dynamic_envision_web/live/home_live/index.ex` | ✅ Placeholder |
| Navigation component | `lib/dynamic_envision_web/components/navigation.ex` | ⏳ Pending |
| Hero component | `lib/dynamic_envision_web/live/hero_live.ex` | ⏳ Pending |
| Portfolio component | `lib/dynamic_envision_web/live/portfolio_live.ex` | ⏳ Pending |
| Contact form | `lib/dynamic_envision_web/live/contact_live.ex` | ⏳ Pending |
| `src/index.css` | `assets/css/app.css` | ✅ Migrated |
| `src/assets/pictures/` | `priv/static/images/` | ✅ Migrated (21 images) |
| Image shuffling logic | `lib/dynamic_envision/photos/photo_shuffle.ex` | ⏳ Next |

---

## Dependencies Installed

### Production
- phoenix ~> 1.7.14
- phoenix_ecto ~> 4.6
- ecto_sql ~> 3.11
- postgrex >= 0.0.0
- phoenix_html ~> 4.1
- phoenix_live_view ~> 1.0.0
- floki >= 0.30.0
- phoenix_live_dashboard ~> 0.8.3
- swoosh ~> 1.16
- finch ~> 0.18
- telemetry_metrics ~> 1.0
- telemetry_poller ~> 1.1
- gettext ~> 0.26
- jason ~> 1.4
- dns_cluster ~> 0.1.1
- bandit ~> 1.5
- tailwind ~> 0.2
- esbuild ~> 0.8
- heroicons (via GitHub)

### Development
- phoenix_live_reload ~> 1.5
- credo ~> 1.7
- dialyxir ~> 1.4
- ex_doc ~> 0.34

### Test
- mox ~> 1.1
- wallaby ~> 0.29.0
- excoveralls ~> 0.18

---

## Next Steps

1. ✅ Phase 1 complete - Phoenix project initialized
2. 🔄 Phase 2 in progress - Create PhotoShuffle module
3. ⏳ Phase 3 pending - Build LiveView components
4. ⏳ Phase 4 pending - Testing & CI/CD

---

## Notes & Gotchas

### Network Issues During Setup
- APT repositories had temporary connectivity issues
- Created all Phoenix files manually instead of using `mix phx.new`
- User will need to run `mix deps.get` when network is available

### Version Choices
- **Elixir 1.18** - Latest stable, not bleeding edge (1.19 skipped)
- **Phoenix 1.7** - Latest stable with new component syntax
- **Wallaby 0.29** - Avoiding 0.30 due to known issues

### Design Decisions
- Tailwind CSS configuration preserved from React version
- Ken Burns animation ported to CSS keyframes
- Image handling moved from Vite glob imports to Phoenix static assets
- All 21 images successfully migrated with original filenames

---

## Timeline

- **2024-01-09**: Phase 1 completed - Phoenix project initialized

---

## References

- [Phoenix Framework Documentation](https://hexdocs.pm/phoenix/)
- [Phoenix LiveView Documentation](https://hexdocs.pm/phoenix_live_view/)
- [Elixir 1.18 Release Notes](https://elixir-lang.org/blog/2024/12/20/elixir-v1-18-0-released/)
- [Mox Documentation](https://hexdocs.pm/mox/)
- [Wallaby Documentation](https://hexdocs.pm/wallaby/)
