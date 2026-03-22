# Java / Kotlin

## Tool Matrix

| Rule Category | Tool | Config |
|---|---|---|
| Linter | Checkstyle + PMD | `config/checkstyle.xml` + `config/pmd-ruleset.xml` |
| Formatter | google-java-format (via Spotless) | `build.gradle` / `pom.xml` plugin |
| Type safety | **Skip** — Java/Kotlin are statically typed | — |
| Test + coverage | JUnit 5 + JaCoCo | `build.gradle` / `pom.xml` plugin |
| Duplication | PMD CPD + jscpd | `.jscpd.json` |
| Pre-commit | pre-commit framework | `.pre-commit-config.yaml` |
| Folder-size | Shell script | `scripts/lint-folder-size.sh` |

## Applicable Rules

| # | Category | Applicable? | Notes |
|---|----------|-------------|-------|
| 1 | Cyclomatic complexity | Yes | Checkstyle `CyclomaticComplexity` + PMD |
| 2 | Function length | Yes | Checkstyle `MethodLength` |
| 3 | File length | Yes | Checkstyle `FileLength` |
| 4 | Max parameters | Yes | Checkstyle `ParameterNumber` + PMD |
| 5 | Type safety | **Skip** | Java/Kotlin are statically typed |
| 6 | Code duplication | Yes | PMD CPD + jscpd |
| 7 | Test coverage | Yes | JaCoCo |
| 8 | Max files per dir | Yes | Shell script |
| 9 | Best practices | Yes | Checkstyle + PMD rules |

## Prerequisites

- JDK ≥ 17
- Build tool: Gradle (recommended) or Maven

## Gradle Setup (build.gradle.kts)

```kotlin
plugins {
    java
    checkstyle
    pmd
    jacoco
    id("com.diffplug.spotless") version "6.25.0"
}

// Checkstyle
checkstyle {
    toolVersion = "10.20.0"
    configFile = file("config/checkstyle.xml")
    maxWarnings = 0
}

// PMD
pmd {
    toolVersion = "7.8.0"
    ruleSetFiles = files("config/pmd-ruleset.xml")
    isConsoleOutput = true
}

// JaCoCo coverage
jacoco {
    toolVersion = "0.8.12"
}

tasks.jacocoTestCoverageVerification {
    violationRules {
        rule {
            limit {
                // Rule 7: 80% coverage
                minimum = "0.80".toBigDecimal()
            }
        }
    }
}

tasks.jacocoTestReport {
    reports {
        xml.required.set(true)
        html.required.set(true)
    }
}

// Spotless (formatter)
spotless {
    java {
        googleJavaFormat("1.24.0")
        removeUnusedImports()
        trimTrailingWhitespace()
        endWithNewline()
    }
}

// PMD CPD (copy-paste detection)
tasks.register<de.aaschmid.gradle.plugins.cpd.Cpd>("cpd") {
    language = "java"
    minimumTokenCount = 50
    source = fileTree("src/main/java")
}
```

For CPD, add plugin: `id("de.aaschmid.cpd") version "3.4"`

## Config: config/checkstyle.xml

```xml
<?xml version="1.0"?>
<!DOCTYPE module PUBLIC
  "-//Checkstyle//DTD Checkstyle Configuration 1.3//EN"
  "https://checkstyle.org/dtds/configuration_1_3.dtd">

<module name="Checker">
  <!-- Rule 3: File length -->
  <module name="FileLength">
    <property name="max" value="800"/>
  </module>

  <module name="TreeWalker">
    <!-- Rule 1: Cyclomatic complexity -->
    <module name="CyclomaticComplexity">
      <property name="max" value="10"/>
    </module>

    <!-- Rule 2: Method length -->
    <module name="MethodLength">
      <property name="max" value="120"/>
      <property name="countEmpty" value="false"/>
    </module>

    <!-- Rule 4: Parameter number -->
    <module name="ParameterNumber">
      <property name="max" value="3"/>
    </module>

    <!-- Rule 9: Best practices -->
    <module name="NeedBraces"/>
    <module name="EqualsHashCode"/>
    <module name="MissingSwitchDefault"/>
    <module name="FallThrough"/>
    <module name="IllegalCatch"/>
    <module name="SimplifyBooleanExpression"/>
    <module name="SimplifyBooleanReturn"/>
    <module name="StringLiteralEquality"/>
    <module name="NestedIfDepth">
      <property name="max" value="4"/>
    </module>
    <module name="NestedTryDepth">
      <property name="max" value="3"/>
    </module>

    <!-- Naming -->
    <module name="TypeName"/>
    <module name="MethodName"/>
    <module name="ConstantName"/>
    <module name="PackageName"/>
    <module name="LocalVariableName"/>
    <module name="MemberName"/>
    <module name="ParameterName"/>

    <!-- Imports -->
    <module name="UnusedImports"/>
    <module name="RedundantImport"/>
    <module name="AvoidStarImport"/>
  </module>
</module>
```

## Config: config/pmd-ruleset.xml

```xml
<?xml version="1.0"?>
<ruleset name="Custom"
  xmlns="http://pmd.sourceforge.net/ruleset/2.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://pmd.sourceforge.net/ruleset/2.0.0
    https://pmd.sourceforge.io/ruleset_2_0_0.xsd">

  <description>Project lint rules</description>

  <rule ref="category/java/bestpractices.xml">
    <exclude name="JUnitTestContainsTooManyAsserts"/>
  </rule>

  <rule ref="category/java/codestyle.xml">
    <exclude name="OnlyOneReturn"/>
    <exclude name="AtLeastOneConstructor"/>
  </rule>

  <rule ref="category/java/design.xml">
    <exclude name="LawOfDemeter"/>
  </rule>

  <rule ref="category/java/design.xml/CyclomaticComplexity">
    <properties>
      <property name="methodReportLevel" value="10"/>
    </properties>
  </rule>

  <rule ref="category/java/design.xml/CognitiveComplexity">
    <properties>
      <property name="reportLevel" value="15"/>
    </properties>
  </rule>

  <rule ref="category/java/design.xml/ExcessiveParameterList">
    <properties>
      <property name="minimum" value="4"/>
    </properties>
  </rule>

  <rule ref="category/java/errorprone.xml"/>
  <rule ref="category/java/performance.xml"/>
</ruleset>
```

## Config: .jscpd.json

```json
{
  "threshold": 5,
  "reporters": ["console"],
  "ignore": ["build", ".gradle", ".git", "target", "*.class"],
  "absolute": false,
  "gitignore": true,
  "minTokens": 50,
  "minLines": 5,
  "format": ["java"]
}
```

## Folder-size script: scripts/lint-folder-size.sh

```bash
#!/usr/bin/env bash
MAX_FILES=${1:-10}
SCAN_PATH=${2:-src}
violations=0

while IFS= read -r dir; do
  count=$(find "$dir" -maxdepth 1 -type f \( -name "*.java" -o -name "*.kt" \) ! -name "*Test.java" ! -name "*Test.kt" | wc -l | tr -d ' ')
  if [ "$count" -gt "$MAX_FILES" ]; then
    echo "  $dir/ — $count code files (max: $MAX_FILES)"
    violations=$((violations + 1))
  fi
done < <(find "$SCAN_PATH" -type d -not -path '*/build/*' -not -path '*/.gradle/*' -not -path '*/.git/*' -not -path '*/target/*')

if [ "$violations" -gt 0 ]; then
  echo "✗ $violations director(ies) exceed $MAX_FILES code files"
  exit 1
fi
echo "✓ All directories have ≤ $MAX_FILES code files"
```

## Pre-commit: .pre-commit-config.yaml

```yaml
repos:
  - repo: local
    hooks:
      - id: spotless
        name: spotless format
        entry: ./gradlew spotlessApply
        language: system
        pass_filenames: false

      - id: checkstyle
        name: checkstyle
        entry: ./gradlew checkstyleMain
        language: system
        pass_filenames: false

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
```

Install: `pre-commit install`

## Makefile (wrapping Gradle)

```makefile
.PHONY: lint fmt fmt-check test coverage check-duplication check-folder-size check-all

lint:
	./gradlew checkstyleMain pmdMain

fmt:
	./gradlew spotlessApply

fmt-check:
	./gradlew spotlessCheck

test:
	./gradlew test

coverage:
	./gradlew test jacocoTestCoverageVerification

check-duplication:
	jscpd src/

check-folder-size:
	bash scripts/lint-folder-size.sh 10 src

check-all: lint fmt-check coverage check-duplication check-folder-size
	@echo "✓ All checks passed"
```

## Verification

```bash
make lint               # Checkstyle + PMD pass
make fmt-check          # Spotless reports no diffs
make coverage           # JaCoCo ≥ 80%
make check-duplication  # jscpd finds no excessive duplication
make check-folder-size  # All directories within limit
```

## Notes

- Checkstyle handles most structural rules (complexity, length, params, naming)
- PMD adds deeper analysis (design smells, error-prone patterns, cognitive complexity)
- JaCoCo coverage threshold is enforced via `jacocoTestCoverageVerification` task
- For Maven: use `maven-checkstyle-plugin`, `maven-pmd-plugin`, `jacoco-maven-plugin`
- Kotlin projects: use detekt instead of Checkstyle/PMD for Kotlin-specific rules
  (`detekt.yml` with similar thresholds)
- For multi-module projects, configure plugins in the root `build.gradle.kts`
  with `subprojects { }` block
