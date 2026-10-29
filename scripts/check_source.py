"""Reproducible source checks; these do NOT compile or execute Flutter."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
pubspec = (root / 'pubspec.yaml').read_text(encoding='utf-8')
assert re.search(r'^version: 1\.0\.12\+23$', pubspec, re.M)
main = (root / 'lib/main.dart').read_text(encoding='utf-8')
for marker in ["onPressed:showNewSavingsGoal", "onPressed:showCorrectSavings",
               "onTap:widget.onEraseProfile", "controller:initialSavings",
               "performSavingsAction(data,", "recentAdvisorMessages(history)",
               "financeContext(widget.data)", "return otherLast(",
               "compareCategoryEntries(a,b)"]:
    assert marker in main, f'Missing UI/data connection: {marker}'
for language in ['es', 'en', 'fr', 'de', 'bn']:
    block = main.split("const savingsLabels=", 1)[-1] if 'const savingsLabels=' in main else main
    assert f"'{language}':" in block
for key in ['goalReached', 'initialSavings', 'clearProfile', 'spendSavings']:
    assert main.count(f"'{key}':") == 5, key
assert "'Otro':{'es':'Otro','en':'Other','fr':'Autre','de':'Sonstiges','bn':'অন্যান্য'}" in main
workflow = (root / '.github/workflows/android.yml').read_text(encoding='utf-8')
assert '--build-number=' not in workflow and '--build-name=' not in workflow
for value in ['flutter analyze', 'flutter test', 'flutter build apk --release',
              'flutter build appbundle --release', 'if-no-files-found: error',
              "flutter-version: '3.35.7'", 'jarsigner -verify', 'apksigner']:
    assert value in workflow, value
assert len(list((root / 'test').glob('*_test.dart'))) >= 5
for asset in ['assets/logo.png', 'assets/app_icon.png']:
    assert (root / asset).read_bytes().startswith(b'\x89PNG\r\n\x1a\n')
print('PASS: version, source UI connections, five-language labels, category wiring, workflow gates, assets.')
print('NOT EXECUTED: Flutter analyze/test, Gradle, APK/AAB generation, device/provider tests.')
