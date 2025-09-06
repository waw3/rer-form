---
allowed-tools: all
argument-hint: [--framework <framework>] [--ui-kit <kit>]
description: Frontend framework and tooling setup wizard for existing Laravel projects
---

# Frontend Setup Wizard

Configure frontend framework, UI components, and build tools for your Laravel project.

## Usage

```bash
# Interactive setup
/wizard:frontend:setup

# Specify framework
/wizard:frontend:setup --framework vue3

# With framework and UI kit
/wizard:frontend:setup --framework vue3 --ui-kit quasar

# Quick React setup
/wizard:frontend:setup --framework react --quick
```

## Examples

```bash
# Example 1: Vue 3 with Quasar
/wizard:frontend:setup --framework vue3 --ui-kit quasar

# Example 2: React with Material UI
/wizard:frontend:setup --framework react --ui-kit mui

# Example 3: Alpine.js with Tailwind
/wizard:frontend:setup --framework alpine --ui-kit tailwind

# Example 4: Full interactive setup
/wizard:frontend:setup
```

## Command Execution

```bash
bash .claude/commands/wizard/frontend/scripts/setup.sh "$@"
```

## Supported Frameworks

### Vue 3
- Composition API
- Script Setup syntax
- TypeScript support
- Vue Router
- Pinia state management

### React 18
- Functional components
- React Hooks
- TypeScript support
- React Router
- Redux/Zustand

### Alpine.js
- Lightweight reactive
- Works with Livewire
- Minimal bundle size
- No build step required

### Svelte
- Compile-time optimization
- SvelteKit integration
- TypeScript support
- Built-in state management

### Angular 17
- Full framework
- TypeScript by default
- RxJS observables
- Angular CLI

## UI Component Libraries

### Vue 3 Libraries
1. **Quasar** - Full-featured, mobile-first
2. **Vuetify 3** - Material Design
3. **PrimeVue** - Rich components
4. **Naive UI** - TypeScript-first
5. **Element Plus** - Enterprise UI
6. **Ant Design Vue** - Professional
7. **Arco Design** - ByteDance
8. **Vuestic UI** - Customizable
9. **Headless UI** - Unstyled
10. **Tailwind UI** - Tailwind components

### React Libraries
1. **Material UI** - Material Design
2. **Ant Design** - Enterprise
3. **Chakra UI** - Modular
4. **Mantine** - Full-featured
5. **NextUI** - Beautiful & modern
6. **Headless UI** - Unstyled
7. **React Bootstrap** - Bootstrap
8. **Semantic UI** - User-friendly
9. **Tailwind UI** - Tailwind
10. **Arco Design** - ByteDance

### CSS Frameworks
1. **Tailwind CSS** - Utility-first
2. **Bootstrap 5** - Component-based
3. **Bulma** - Modern CSS
4. **Foundation** - Responsive
5. **UIKit** - Modular
6. **Materialize** - Material Design
7. **Semantic UI** - Human-friendly
8. **Spectre.css** - Lightweight
9. **Tachyons** - Functional
10. **Pure.css** - Minimal

## Build Tools

### Vite (Recommended)
- Lightning fast HMR
- Native ESM
- Optimized builds
- Laravel integration

### Webpack
- Mature ecosystem
- Advanced configuration
- Code splitting
- Laravel Mix support

### esbuild
- Extremely fast
- Go-based bundler
- Minimal configuration
- Tree shaking

### Rollup
- ES module bundler
- Plugin ecosystem
- Tree shaking
- Library mode

## Development Tools

### Linters
- ESLint + Prettier
- Biome (all-in-one)
- XO (opinionated)
- Standard JS

### Type Checking
- TypeScript
- Flow
- PropTypes (React)

### Testing
- Vitest (Vite-native)
- Jest
- Cypress (E2E)
- Playwright
- Testing Library

### Dev Tools
- Vue DevTools
- React DevTools
- Redux DevTools
- Vite Plugin Inspect

## State Management

### Vue 3
- Pinia (recommended)
- Vuex 4
- Valtio
- Jotai

### React
- Redux Toolkit
- Zustand
- Jotai
- Valtio
- MobX

## Common Dependencies

### HTTP Clients
- Axios
- Fetch API
- Ky
- Got

### Form Handling
- FormKit (Vue)
- React Hook Form
- Formik (React)
- VeeValidate (Vue)

### Utilities
- Lodash-es
- Date-fns
- Dayjs
- Ramda

### UI Enhancements
- Swiper (sliders)
- Chart.js (charts)
- Floating UI (tooltips)
- Sortable.js (drag-drop)

## Generated Files

### package.json
```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "lint": "eslint .",
    "format": "prettier --write .",
    "type-check": "tsc --noEmit"
  }
}
```

### vite.config.js
Configured for selected framework

### tsconfig.json
TypeScript configuration

### .eslintrc.js
Linting rules

### prettier.config.js
Code formatting

### tailwind.config.js
If Tailwind selected

## Integration with Laravel

The wizard automatically:
- Configures Vite with Laravel plugin
- Sets up hot module replacement
- Creates blade entry point
- Configures asset paths
- Sets up API proxy

## Post-Setup Commands

```bash
# Install dependencies
npm install

# Start dev server
npm run dev

# Build for production
npm run build

# Run linting
npm run lint

# Format code
npm run format

# Type checking
npm run type-check
```

## Requirements

- Node.js 18+
- npm/yarn/pnpm
- Existing Laravel project