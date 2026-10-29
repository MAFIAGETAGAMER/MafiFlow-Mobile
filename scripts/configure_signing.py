import os
import base64
from pathlib import Path

required = [
    'KEYSTORE_BASE64',
    'KEYSTORE_PASSWORD',
    'KEY_ALIAS',
    'KEY_PASSWORD'
]

for name in required:
    if not os.environ.get(name):
        raise RuntimeError(f'Missing GitHub secret: {name}')

android = Path('android')
keystore = android / 'mafistudio-release.jks'

keystore.write_bytes(
    base64.b64decode(
        os.environ['KEYSTORE_BASE64'].strip(),
        validate=True
    )
)

if not keystore.stat().st_size:
    raise RuntimeError('Keystore is empty')

properties = android / 'key.properties'

def escape_property(value):
    # Properties.load(InputStream) expects Latin-1, not UTF-8. Escaping every
    # UTF-16 code unit also preserves leading spaces and password punctuation.
    encoded = value.encode('utf-16-be')
    return ''.join('\\u' + encoded[i:i+2].hex()
                   for i in range(0, len(encoded), 2))

properties.write_text(
    'storePassword=' + escape_property(os.environ['KEYSTORE_PASSWORD']) + '\n'
    'keyPassword=' + escape_property(os.environ['KEY_PASSWORD']) + '\n'
    'keyAlias=' + escape_property(os.environ['KEY_ALIAS']) + '\n'
    'storeFile=mafistudio-release.jks\n'
)

gradle_kts = android / 'app/build.gradle.kts'
gradle_groovy = android / 'app/build.gradle'

if gradle_kts.exists():
    text = gradle_kts.read_text()

    imports = (
        'import java.util.Properties\n'
        'import java.io.FileInputStream\n'
    )

    if 'import java.util.Properties' not in text:
        text = imports + text

    config = '''
val releaseKeystoreProperties = Properties()
val releaseKeystoreFile = rootProject.file("key.properties")

FileInputStream(releaseKeystoreFile).use {
    releaseKeystoreProperties.load(it)
}

'''

    if 'val releaseKeystoreProperties' not in text:
        text = text.replace(
            'android {',
            config + 'android {',
            1
        )

    signing = '''
    create("release") {
        keyAlias = releaseKeystoreProperties["keyAlias"] as String
        keyPassword = releaseKeystoreProperties["keyPassword"] as String
        storeFile = rootProject.file(releaseKeystoreProperties["storeFile"] as String)
        storePassword = releaseKeystoreProperties["storePassword"] as String
    }
'''

    text = text.replace(
        'buildTypes {',
        'signingConfigs {\n' + signing + '    }\n\n    buildTypes {',
        1
    )

    text = text.replace(
        'signingConfig = signingConfigs.getByName("debug")',
        'signingConfig = signingConfigs.getByName("release")'
    )

    if 'signingConfig = signingConfigs.getByName("release")' not in text:
        raise RuntimeError('Could not configure release signing')

    gradle_kts.write_text(text)

elif gradle_groovy.exists():
    text = gradle_groovy.read_text()

    config = '''
def releaseKeystoreProperties = new Properties()
def releaseKeystoreFile = rootProject.file('key.properties')

releaseKeystoreProperties.load(
    new FileInputStream(releaseKeystoreFile)
)

'''

    text = text.replace(
        'android {',
        config + 'android {',
        1
    )

    signing = '''
    release {
        keyAlias releaseKeystoreProperties['keyAlias']
        keyPassword releaseKeystoreProperties['keyPassword']
        storeFile rootProject.file(releaseKeystoreProperties['storeFile'])
        storePassword releaseKeystoreProperties['storePassword']
    }
'''

    text = text.replace(
        'buildTypes {',
        'signingConfigs {\n' + signing + '    }\n\n    buildTypes {',
        1
    )

    text = text.replace(
        'signingConfig signingConfigs.debug',
        'signingConfig signingConfigs.release'
    )

    if 'signingConfig signingConfigs.release' not in text:
        raise RuntimeError('Could not configure release signing')

    gradle_groovy.write_text(text)

else:
    raise RuntimeError('Android Gradle configuration not found')

print('Official Mafistudio release signing configured')
