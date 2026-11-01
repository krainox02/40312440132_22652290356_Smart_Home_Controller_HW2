"""Create a portable source-only submission; never include local SDK/cache files."""
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile

ROOT = Path(__file__).resolve().parents[1]
NAME = 'HW2_Tarik_Ata_Kilic_40312440132_Ata_Turan_22652290356'
EXCLUDED_DIRS = {'.git', '.dart_tool', '.idea', 'build', 'output', 'tmp', '.gradle', '.kotlin', '__pycache__', 'ephemeral'}
EXCLUDED_FILES = {'local.properties', '.flutter-plugins-dependencies', '.DS_Store', '.last_build_id'}


def package():
    destination = ROOT / 'output' / f'{NAME}.zip'
    destination.parent.mkdir(exist_ok=True)
    included = []
    with ZipFile(destination, 'w', compression=ZIP_DEFLATED, compresslevel=9) as archive:
        for path in sorted(ROOT.rglob('*')):
            if not path.is_file():
                continue
            relative = path.relative_to(ROOT)
            if any(part in EXCLUDED_DIRS for part in relative.parts):
                continue
            if path.name in EXCLUDED_FILES or path.suffix in {'.iml', '.log', '.pyc'}:
                continue
            # Flutter regenerates these files with the recipient's machine paths.
            if path.name in {'Generated.xcconfig', 'flutter_export_environment.sh'}:
                continue
            archive.write(path, f'{NAME}/{relative.as_posix()}')
            included.append(relative.as_posix())
    print(f'{destination}\n{len(included)} files; {destination.stat().st_size:,} bytes')
    return destination


if __name__ == '__main__':
    package()
