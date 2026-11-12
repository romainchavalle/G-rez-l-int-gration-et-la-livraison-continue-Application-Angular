#!/usr/bin/env bash
set -euo pipefail

# 1. Clean previous test artifacts
echo "Cleaning previous test results..."
rm -rf test-results
mkdir -p test-results

# 2. Automatically detect project type and run unit tests
if [ -f "package.json" ]; then
    echo "Node.js / Angular project detected."
    rm -rf reports

    # Check if npm is installed
    if ! command -v npm >/dev/null 2>&1; then
        echo "Error: npm is not installed."
        exit 1
    fi

    # Check if dependencies exist before running tests
    if [ ! -d "node_modules" ]; then
        echo "node_modules directory not found. Installing dependencies with npm ci..."
        npm ci
    fi

    # Run Angular unit tests
    echo "Running Angular unit tests..."
    npm test

    # Copy generated JUnit XML report(s) to test-results/
    if compgen -G "reports/*.xml" > /dev/null; then
        cp reports/*.xml test-results/
        echo "JUnit XML report(s) successfully copied to test-results/"
    else
        echo "Error: No JUnit XML report generated in reports/."
        exit 1
    fi

elif [ -f "build.gradle" ]; then
    echo "Java / Gradle project detected."

    # Check if Java is installed
    if ! command -v java >/dev/null 2>&1; then
        echo "Error: Java (JDK) is not installed."
        exit 1
    fi

    # Check if Gradle wrapper exists
    if [ ! -f "./gradlew" ]; then
        echo "Error: Gradle wrapper (./gradlew) not found."
        exit 1
    fi

    # Normalize line endings and ensure ./gradlew is executable
    sed -i 's/\r$//' ./gradlew 2>/dev/null || true
    chmod +x ./gradlew

    # Run Java unit tests (clean removes previous Gradle test artifacts)
    echo "Running Java unit tests with Gradle..."
    ./gradlew clean test --no-daemon

    # Copy generated JUnit XML report(s) to test-results/
    if compgen -G "build/test-results/test/*.xml" > /dev/null; then
        cp build/test-results/test/*.xml test-results/
        echo "JUnit XML report(s) successfully copied to test-results/"
    else
        echo "Error: No JUnit XML report generated in build/test-results/test/."
        exit 1
    fi

else
    echo "Error: Unrecognized project type (neither package.json nor build.gradle found)."
    exit 1
fi

echo "All unit tests passed successfully!"
exit 0
