"""Offline synthetic configuration tests; no Gradle/signature claims."""
import base64
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPTS = Path(__file__).resolve().parent

class BuildConfigTests(unittest.TestCase):
    def run_script(self, script, root, env=None):
        return subprocess.run([sys.executable, str(SCRIPTS / script)],
                              cwd=root, env=env, capture_output=True, text=True)

    def test_manifest_is_idempotent(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            manifest = root / 'android/app/src/main/AndroidManifest.xml'
            manifest.parent.mkdir(parents=True)
            manifest.write_text('<manifest xmlns:android="http://schemas.android.com/apk/res/android"><application android:label="mafiflow_mobile" /></manifest>')
            for _ in range(2):
                result = self.run_script('configure_manifest.py', root)
                self.assertEqual(result.returncode, 0, result.stderr)
            result = manifest.read_text()
            self.assertEqual(result.count('android.permission.INTERNET'), 1)
            self.assertIn('android:label="MafiFlow"', result)

    def test_missing_secret_stops_release(self):
        with tempfile.TemporaryDirectory() as folder:
            env = {k: v for k, v in os.environ.items()
                   if k not in ['KEYSTORE_BASE64', 'KEYSTORE_PASSWORD', 'KEY_ALIAS', 'KEY_PASSWORD']}
            result = self.run_script('configure_signing.py', folder, env)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('Missing GitHub secret', result.stderr)

    def test_signing_patches_both_templates(self):
        for suffix, default in [('.kts', 'signingConfig = signingConfigs.getByName("debug")'),
                                ('', 'signingConfig signingConfigs.debug')]:
            with self.subTest(suffix=suffix), tempfile.TemporaryDirectory() as folder:
                root = Path(folder)
                gradle = root / ('android/app/build.gradle' + suffix)
                gradle.parent.mkdir(parents=True)
                gradle.write_text('plugins {}\nandroid {\n buildTypes {\n release {\n' + default + '\n }\n }\n}\n')
                env = dict(os.environ, KEYSTORE_BASE64=base64.b64encode(b'SYNTHETIC-NOT-A-KEYSTORE').decode(),
                           KEYSTORE_PASSWORD=' leading\\space:=#é', KEY_PASSWORD='dummy', KEY_ALIAS='alias')
                result = self.run_script('configure_signing.py', root, env)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertNotIn(default, gradle.read_text())
                self.assertIn('signingConfigs', gradle.read_text())
                properties = (root / 'android/key.properties').read_text()
                self.assertIn('storePassword=\\u0020', properties)
                self.assertIn('\\u00e9', properties)

if __name__ == '__main__':
    unittest.main(verbosity=2)
