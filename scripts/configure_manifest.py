from pathlib import Path
import re

manifest = Path('android/app/src/main/AndroidManifest.xml')
text = manifest.read_text()

permission = '<uses-permission android:name="android.permission.INTERNET" />'

if 'android.permission.INTERNET' not in text:
    text = text.replace(
        '<application',
        permission + '\n    <application',
        1
    )

text, count = re.subn(
    r'android:label="[^"]*"',
    'android:label="MafiFlow"',
    text,
    count=1
)

assert count == 1, 'Android app label not found'
manifest.write_text(text)
print('MafiFlow name configured')
print('Internet permission enabled')
