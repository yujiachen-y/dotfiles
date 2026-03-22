# TypeScript / JavaScript

## Tool Matrix

| Rule Category | Tool | Config |
|---|---|---|
| Linter | ESLint 9+ (flat config) + @typescript-eslint + eslint-plugin-sonarjs | `eslint.config.ts` |
| Formatter | Prettier | `.prettierrc` + `.prettierignore` |
| Type safety | TypeScript strict mode + ESLint rules | `tsconfig.base.json` |
| Test + coverage | Vitest + @vitest/coverage-v8 | `vitest.config.ts` |
| Duplication | jscpd + sonarjs rules | `.jscpd.json` |
| Pre-commit | husky + lint-staged | `.husky/pre-commit` + `.lintstagedrc.json` |
| Folder-size | Custom script in TypeScript | `scripts/lint-folder-size.ts` |

## Applicable Rules (all 9 apply)

All 9 rule categories apply to TypeScript.

## Prerequisites

- Node.js ≥ 18
- A package manager: pnpm (recommended), npm, yarn, or bun

## Package Manager Choice

Ask the user. Recommend pnpm for monorepos. The examples below use pnpm.

## Installation

```bash
pnpm add -Dw \
  typescript \
  eslint \
  @typescript-eslint/parser \
  @typescript-eslint/eslint-plugin \
  typescript-eslint \
  eslint-plugin-sonarjs \
  eslint-config-prettier \
  prettier \
  jscpd \
  vitest @vitest/coverage-v8 \
  husky lint-staged \
  tsx \
  jiti
```

## Config: tsconfig.base.json

For monorepos, this is the shared base config. Each package extends it.

```jsonc
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "Node16",
    "moduleResolution": "Node16",
    "lib": ["ES2022"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true,
    "noFallthroughCasesInSwitch": true,
    "verbatimModuleSyntax": true
  }
}
```

## Config: tsconfig.json (root)

```jsonc
{
  "extends": "./tsconfig.base.json",
  "compilerOptions": { "noEmit": true },
  "include": ["scripts/**/*.ts", "eslint.config.ts", "vitest.config.ts"],
  "exclude": ["node_modules", "dist", "build", "coverage"]
}
```

For monorepos, add project references as packages are created.

## Config: eslint.config.ts

Use ESLint flat config with `defineConfig` from `eslint/config`:

```typescript
import { defineConfig } from 'eslint/config';
import tseslint from 'typescript-eslint';
import sonarjs from 'eslint-plugin-sonarjs';
import prettierConfig from 'eslint-config-prettier';
```

### Ignores

```typescript
{ ignores: ['**/node_modules/**', '**/dist/**', '**/build/**', '**/coverage/**'] }
```

### Base configs

```typescript
...tseslint.configs.strictTypeChecked,
...tseslint.configs.stylisticTypeChecked,
```

### Parser options

```typescript
{
  languageOptions: {
    parserOptions: {
      projectService: true,
      tsconfigRootDir: import.meta.dirname,
    },
  },
}
```

### SonarJS

```typescript
sonarjs.configs.recommended,
```

### Rule mapping

Apply these ESLint rules to cover the 9 categories. Replace `<threshold>` with user-chosen
values (or defaults from SKILL.md):

| Category | ESLint Rule | Config |
|---|---|---|
| 1. Cyclomatic complexity | `complexity` | `['error', { max: <threshold> }]` |
| 2. Function length | `max-lines-per-function` | `['error', { max: <threshold>, skipBlankLines: true, skipComments: true }]` |
| 3. File length | `max-lines` | `['error', { max: <threshold>, skipBlankLines: true, skipComments: true }]` |
| 4. Max params | `max-params` | `['error', { max: <threshold> }]` |
| 5a. Explicit return types | `@typescript-eslint/explicit-function-return-type` | `['error', { allowExpressions: true, allowTypedFunctionExpressions: true, allowHigherOrderFunctions: true, allowDirectConstAssertionInArrowFunctions: true }]` |
| 5b. No any | `@typescript-eslint/no-explicit-any` | `'error'` |
| 5c. Unused vars | `@typescript-eslint/no-unused-vars` | `['error', { argsIgnorePattern: '^_', varsIgnorePattern: '^_' }]` |
| 5d. Type imports | `@typescript-eslint/consistent-type-imports` | `['error', { prefer: 'type-imports', fixStyle: 'inline-type-imports' }]` |
| 5e. Type exports | `@typescript-eslint/consistent-type-exports` | `['error', { fixMixedExportsWithInlineTypeSpecifier: true }]` |
| 6a. Duplicate strings | `sonarjs/no-duplicate-string` | `['error', { threshold: 3 }]` |
| 6b. Identical functions | `sonarjs/no-identical-functions` | `'error'` |
| 9a. Cognitive complexity | `sonarjs/cognitive-complexity` | `['error', 15]` |
| 9b. Nesting depth | `max-depth` | `['error', { max: 4 }]` |
| 9c. Callback nesting | `max-nested-callbacks` | `['error', { max: 3 }]` |
| 9d. No console | `no-console` | `['warn', { allow: ['warn', 'error'] }]` |
| 9e. Strict equality | `eqeqeq` | `['error', 'always']` |
| 9f. No eval | `no-eval` | `'error'` |
| 9g. Prefer const | `prefer-const` | `'error'` |
| 9h. Curly braces | `curly` | `['error', 'all']` |

### Naming conventions

```typescript
'@typescript-eslint/naming-convention': [
  'error',
  { selector: 'interface', format: ['PascalCase'] },
  { selector: 'typeAlias', format: ['PascalCase'] },
  { selector: 'enum', format: ['PascalCase'] },
  { selector: 'enumMember', format: ['PascalCase'] },
],
```

### Promise safety

```typescript
'@typescript-eslint/no-floating-promises': 'error',
'@typescript-eslint/no-misused-promises': 'error',
```

### Prettier (always last)

```typescript
prettierConfig,
```

## Config: .prettierrc

```json
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2,
  "arrowParens": "always",
  "endOfLine": "lf"
}
```

## Config: vitest.config.ts

```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',
      reporter: ['text', 'text-summary', 'lcov'],
      thresholds: {
        statements: 80,
        branches: 80,
        functions: 80,
        lines: 80,
      },
      exclude: [
        'node_modules/**', 'dist/**', 'build/**', 'coverage/**',
        '**/*.config.*', '**/*.d.ts', 'scripts/**',
      ],
    },
  },
});
```

## Config: .jscpd.json

```json
{
  "threshold": 5,
  "reporters": ["console"],
  "ignore": ["node_modules", "dist", "build", "coverage", "**/*.config.*", "**/*.d.ts", "pnpm-lock.yaml"],
  "absolute": false,
  "gitignore": true,
  "minTokens": 50,
  "minLines": 5,
  "format": ["typescript", "javascript", "tsx", "jsx"]
}
```

## Config: .lintstagedrc.json

```json
{
  "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
  "*.{js,jsx}": ["eslint --fix", "prettier --write"],
  "*.{json,yaml,yml,md}": ["prettier --write"]
}
```

## Folder-size script

Write `scripts/lint-folder-size.ts` in TypeScript. Count `.ts`, `.tsx`, `.js`, `.jsx` files.
Run via `tsx scripts/lint-folder-size.ts`. See the SKILL.md for the script contract.

## package.json scripts

```json
{
  "lint": "eslint .",
  "lint:fix": "eslint . --fix",
  "format": "prettier --write .",
  "format:check": "prettier --check .",
  "typecheck": "tsc --noEmit",
  "test": "vitest run",
  "test:watch": "vitest",
  "test:coverage": "vitest run --coverage",
  "check:duplication": "jscpd ./packages",
  "check:folder-size": "tsx scripts/lint-folder-size.ts",
  "check:all": "pnpm lint && pnpm format:check && pnpm typecheck && pnpm check:duplication && pnpm check:folder-size",
  "prepare": "husky"
}
```

Adjust `check:duplication` path to match project structure (e.g., `./src` instead of `./packages`).

## package.json essentials

Make sure to include:

```json
{
  "private": true,
  "type": "module"
}
```

## Husky setup

```bash
pnpm exec husky init
```

Then write `.husky/pre-commit`:

```bash
pnpm exec lint-staged
```

## Verification

```bash
pnpm lint          # ESLint passes
pnpm format:check  # Prettier reports no diffs
pnpm typecheck     # tsc --noEmit passes
pnpm check:duplication   # jscpd finds no excessive duplication
pnpm check:folder-size   # All directories within limit
```

## Notes

- For monorepos, use `pnpm-workspace.yaml` with `packages: ['packages/*']`
- ESLint 10+ requires `jiti` for loading `.ts` config files — include it in devDependencies
- Prettier must be the **last** config in the ESLint config to disable conflicting format rules
- The root `tsconfig.json` should include all root-level `.ts` files (eslint config, vitest config, scripts)
