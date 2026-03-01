---
name: setup_php_project
description: Use this skill to set up a basic PHP project. It initializes Composer, installs testing and static analysis tools (PHPUnit, PHPStan, PHP_CodeSniffer), and provisions basic configuration files (phpstan.neon.dist and phpcs.xml).
---

# Setting Up a Basic PHP Project

When the user asks you to initialize or set up a basic PHP project, follow these steps:

## 1. Initialize Composer

First, check if `composer.json` exists in the project root.
If it does not exist, initialize composer with default values by running:

```bash
composer init --no-interaction
```

## 2. Install Dependencies

Install the required development dependencies. Run the following command:

```bash
composer require --dev phpunit/phpunit phpstan/phpstan squizlabs/php_codesniffer slevomat/coding-standard
```

## 3. Configure PHPStan

Check if `phpstan.neon.dist` exists. If not, copy the `phpstan.neon.dist` template from this skill's `resources` directory to the project root:

```bash
cp ./resources/phpstan.neon.dist .
```

> [!NOTE]
> The source path `./resources/phpstan.neon.dist` is relative to the directory of this skill. Ensure you are in the skill directory or provide the correct relative path when executing the copy command.

Make sure to adjust the `paths` in the copied file if the project uses different directories for its source code and tests.

## 4. Configure PHP_CodeSniffer

Check if `phpcs.xml` exists. If not, copy the `phpcs.xml` template from this skill's `resources` directory to the project root to enforce PSR-12 coding standards:

```bash
cp ./resources/phpcs.xml .
```

> [!NOTE]
> The source path `./resources/phpcs.xml` is relative to the directory of this skill. Ensure you are in the skill directory or provide the correct relative path when executing the copy command.

You may need to create `src` and `tests` directories if they do not exist, as these configuration files expect them.

## 5. Review

Once the setup is complete, verify that the files have been created and the dependencies are properly listed in `composer.json`. Inform the user that the PHP project has been successfully initialized and configured with PHPUnit, PHPStan, and PHP_CodeSniffer.
