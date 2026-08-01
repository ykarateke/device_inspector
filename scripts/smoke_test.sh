#!/bin/bash
# Smoke tests — quick validation before committing.
set -e

echo "=== device_inspector Smoke Tests ==="

echo ""
echo "1. Static analysis..."
dart analyze || { echo "FAILED"; exit 1; }
echo "   PASSED"

echo ""
echo "2. Formatting check..."
dart format --output=none --set-exit-if-changed . || { echo "FAILED"; exit 1; }
echo "   PASSED"

echo ""
echo "3. Unit tests..."
flutter test --reporter compact || { echo "FAILED"; exit 1; }
echo "   PASSED"

echo ""
echo "=== All smoke tests passed ==="
