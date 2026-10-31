"""Example-only workaround for missing Flavorizr AppIcon catalogs."""
from pathlib import Path

root=Path(__file__).resolve().parent.parent
project=root/'flutter_example/ios/Runner.xcodeproj/project.pbxproj'
source=project.read_text()
patched=source.replace('ASSETCATALOG_COMPILER_APPICON_NAME = "AppIcon-$(ASSET_PREFIX)";', 'ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;')
if patched != source:
    project.write_text(patched)
    print('Example now reuses the existing AppIcon catalog for all flavors.')
else:
    print('No missing flavor icon references needed replacement.')
