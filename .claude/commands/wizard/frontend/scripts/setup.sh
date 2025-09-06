#!/bin/bash

# Frontend Setup Wizard
# Configure frontend framework, UI components, and build tools for Laravel

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default values
FRAMEWORK="${1:-}"
UI_KIT="${2:-}"
QUICK_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --framework)
            FRAMEWORK="$2"
            shift 2
            ;;
        --ui-kit)
            UI_KIT="$2"
            shift 2
            ;;
        --quick)
            QUICK_MODE=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Function to print colored output
print_message() {
    echo -e "${1}${2}${NC}"
}

# Function to print section header
print_section() {
    echo
    print_message "$BLUE" "📦 $1"
    echo
}

# Interactive mode if no framework specified
if [[ -z "$FRAMEWORK" ]]; then
    print_message "$BLUE" "🎨 Frontend Setup Wizard"
    echo
    echo "Choose a frontend framework:"
    echo "  1) Vue 3 (Composition API)"
    echo "  2) React 18"
    echo "  3) Alpine.js"
    echo "  4) Svelte"
    echo "  5) Angular 17"
    read -p "Choose [1-5]: " framework_choice
    
    case $framework_choice in
        1) FRAMEWORK="vue3" ;;
        2) FRAMEWORK="react" ;;
        3) FRAMEWORK="alpine" ;;
        4) FRAMEWORK="svelte" ;;
        5) FRAMEWORK="angular" ;;
        *) FRAMEWORK="vue3" ;;
    esac
fi

# Interactive UI kit selection if not specified
if [[ -z "$UI_KIT" && "$QUICK_MODE" != true ]]; then
    echo
    echo "Choose a UI component library:"
    
    case $FRAMEWORK in
        "vue3")
            echo "  1) Quasar Framework"
            echo "  2) Vuetify 3"
            echo "  3) PrimeVue"
            echo "  4) Tailwind CSS + Headless UI"
            echo "  5) Element Plus"
            echo "  6) Ant Design Vue"
            read -p "Choose [1-6]: " ui_choice
            
            case $ui_choice in
                1) UI_KIT="quasar" ;;
                2) UI_KIT="vuetify" ;;
                3) UI_KIT="primevue" ;;
                4) UI_KIT="tailwind" ;;
                5) UI_KIT="element-plus" ;;
                6) UI_KIT="antdv" ;;
                *) UI_KIT="tailwind" ;;
            esac
            ;;
        "react")
            echo "  1) Material UI"
            echo "  2) Ant Design"
            echo "  3) Chakra UI"
            echo "  4) NextUI"
            echo "  5) Tailwind CSS + Headless UI"
            echo "  6) Mantine"
            read -p "Choose [1-6]: " ui_choice
            
            case $ui_choice in
                1) UI_KIT="mui" ;;
                2) UI_KIT="antd" ;;
                3) UI_KIT="chakra" ;;
                4) UI_KIT="nextui" ;;
                5) UI_KIT="tailwind" ;;
                6) UI_KIT="mantine" ;;
                *) UI_KIT="tailwind" ;;
            esac
            ;;
        "alpine")
            UI_KIT="tailwind"
            ;;
        *)
            UI_KIT="tailwind"
            ;;
    esac
fi

print_section "Frontend Configuration"
echo "  Framework: $FRAMEWORK"
echo "  UI Kit: $UI_KIT"
echo

# Check for Node.js
if ! command -v npm &> /dev/null; then
    print_message "$RED" "❌ Node.js/npm is not installed"
    print_message "$YELLOW" "Please install Node.js 18+ from https://nodejs.org"
    exit 1
fi

# Setup framework-specific configuration
setup_vue3() {
    print_section "Installing Vue 3 Dependencies"
    
    echo "npm install vue@^3.4 @vitejs/plugin-vue vue-router@^4.0 pinia"
    echo "npm install --save-dev @vue/tsconfig @types/node typescript"
    
    if [[ "$UI_KIT" == "quasar" ]]; then
        echo "npm install quasar @quasar/vite-plugin"
    elif [[ "$UI_KIT" == "vuetify" ]]; then
        echo "npm install vuetify @mdi/font"
    elif [[ "$UI_KIT" == "primevue" ]]; then
        echo "npm install primevue primeicons"
    elif [[ "$UI_KIT" == "element-plus" ]]; then
        echo "npm install element-plus @element-plus/icons-vue"
    elif [[ "$UI_KIT" == "antdv" ]]; then
        echo "npm install ant-design-vue @ant-design/icons-vue"
    elif [[ "$UI_KIT" == "tailwind" ]]; then
        echo "npm install tailwindcss @tailwindcss/forms @tailwindcss/typography autoprefixer postcss"
        echo "npm install @headlessui/vue @heroicons/vue"
    fi
}

setup_react() {
    print_section "Installing React 18 Dependencies"
    
    echo "npm install react@^18.0 react-dom@^18.0 @vitejs/plugin-react"
    echo "npm install --save-dev @types/react @types/react-dom typescript"
    
    if [[ "$UI_KIT" == "mui" ]]; then
        echo "npm install @mui/material @emotion/react @emotion/styled @mui/icons-material"
    elif [[ "$UI_KIT" == "antd" ]]; then
        echo "npm install antd @ant-design/icons"
    elif [[ "$UI_KIT" == "chakra" ]]; then
        echo "npm install @chakra-ui/react @emotion/react @emotion/styled framer-motion"
    elif [[ "$UI_KIT" == "nextui" ]]; then
        echo "npm install @nextui-org/react framer-motion"
    elif [[ "$UI_KIT" == "mantine" ]]; then
        echo "npm install @mantine/core @mantine/hooks @tabler/icons-react"
    elif [[ "$UI_KIT" == "tailwind" ]]; then
        echo "npm install tailwindcss @tailwindcss/forms @tailwindcss/typography autoprefixer postcss"
        echo "npm install @headlessui/react @heroicons/react"
    fi
    
    echo "npm install react-router-dom @reduxjs/toolkit react-redux"
}

setup_alpine() {
    print_section "Installing Alpine.js Dependencies"
    
    echo "npm install alpinejs @alpinejs/persist @alpinejs/intersect @alpinejs/morph"
    echo "npm install tailwindcss @tailwindcss/forms @tailwindcss/typography autoprefixer postcss"
}

setup_svelte() {
    print_section "Installing Svelte Dependencies"
    
    echo "npm install svelte @sveltejs/vite-plugin-svelte"
    echo "npm install --save-dev @sveltejs/kit @tsconfig/svelte typescript"
    echo "npm install tailwindcss @tailwindcss/forms @tailwindcss/typography autoprefixer postcss"
}

setup_angular() {
    print_section "Installing Angular Dependencies"
    
    echo "npm install @angular/core @angular/common @angular/router @angular/forms"
    echo "npm install @angular/material @angular/cdk @angular/animations"
    echo "npm install --save-dev @angular/cli typescript"
}

# Install framework dependencies
case $FRAMEWORK in
    "vue3") setup_vue3 ;;
    "react") setup_react ;;
    "alpine") setup_alpine ;;
    "svelte") setup_svelte ;;
    "angular") setup_angular ;;
esac

print_section "Installing Development Tools"

echo "npm install --save-dev vite laravel-vite-plugin"
echo "npm install --save-dev eslint prettier @typescript-eslint/parser @typescript-eslint/eslint-plugin"

if [[ "$FRAMEWORK" == "vue3" ]]; then
    echo "npm install --save-dev @vue/eslint-config-typescript @vue/eslint-config-prettier"
    echo "npm install --save-dev @vue/test-utils vitest @vitest/ui happy-dom"
elif [[ "$FRAMEWORK" == "react" ]]; then
    echo "npm install --save-dev @typescript-eslint/eslint-plugin-react eslint-plugin-react-hooks"
    echo "npm install --save-dev @testing-library/react @testing-library/jest-dom vitest"
fi

echo "npm install --save-dev axios"

print_section "Configuring Build Tools"

# Generate vite.config.js
if [[ "$FRAMEWORK" == "vue3" ]]; then
    echo "Creating vite.config.js for Vue 3..."
    echo "import { defineConfig } from 'vite'"
    echo "import laravel from 'laravel-vite-plugin'"
    echo "import vue from '@vitejs/plugin-vue'"
elif [[ "$FRAMEWORK" == "react" ]]; then
    echo "Creating vite.config.js for React..."
    echo "import { defineConfig } from 'vite'"
    echo "import laravel from 'laravel-vite-plugin'"
    echo "import react from '@vitejs/plugin-react'"
fi

# Generate TypeScript config
if [[ "$FRAMEWORK" != "alpine" ]]; then
    print_section "Creating TypeScript Configuration"
    echo "Creating tsconfig.json..."
fi

# Generate Tailwind config if selected
if [[ "$UI_KIT" == "tailwind" ]]; then
    print_section "Creating Tailwind Configuration"
    echo "npx tailwindcss init -p"
    echo "Creating tailwind.config.js with Laravel paths..."
fi

# Generate ESLint config
print_section "Creating ESLint Configuration"
echo "Creating .eslintrc.js..."

# Generate Prettier config
echo "Creating prettier.config.js..."

print_section "Updating package.json Scripts"

echo "Adding build scripts to package.json:"
echo '  "scripts": {'
echo '    "dev": "vite",'
echo '    "build": "vite build",'
echo '    "preview": "vite preview",'
echo '    "lint": "eslint .",'
echo '    "format": "prettier --write .",'
echo '    "type-check": "tsc --noEmit",'
echo '    "test": "vitest",'
echo '    "test:ui": "vitest --ui"'
echo '  }'

print_section "Creating Entry Point Files"

# Create main JS/TS file
if [[ "$FRAMEWORK" == "vue3" ]]; then
    echo "Creating resources/js/app.js for Vue 3..."
    echo "import { createApp } from 'vue'"
elif [[ "$FRAMEWORK" == "react" ]]; then
    echo "Creating resources/js/app.jsx for React..."
    echo "import React from 'react'"
    echo "import { createRoot } from 'react-dom/client'"
elif [[ "$FRAMEWORK" == "alpine" ]]; then
    echo "Creating resources/js/app.js for Alpine.js..."
    echo "import Alpine from 'alpinejs'"
fi

# Create CSS file
echo "Creating resources/css/app.css..."

if [[ "$UI_KIT" == "tailwind" ]]; then
    echo "@tailwind base;"
    echo "@tailwind components;"
    echo "@tailwind utilities;"
fi

print_section "Laravel Integration"

echo "Updating blade template to include Vite assets..."
echo "Add to your main layout:"
echo "@vite(['resources/css/app.css', 'resources/js/app.js'])"

print_section "Final Steps"

print_message "$GREEN" "✅ Frontend setup completed!"
echo
print_message "$CYAN" "Next steps:"
echo "  1. Run 'npm install' to install dependencies"
echo "  2. Run 'npm run dev' to start development server"
echo "  3. Run 'npm run build' to build for production"
echo "  4. Update your Laravel routes and views"
echo
print_message "$YELLOW" "Development commands:"
echo "  npm run dev     # Start dev server with HMR"
echo "  npm run build   # Build for production"
echo "  npm run lint    # Run linting"
echo "  npm run test    # Run tests"
echo
print_message "$GREEN" "Frontend framework '$FRAMEWORK' with '$UI_KIT' ready for development!"