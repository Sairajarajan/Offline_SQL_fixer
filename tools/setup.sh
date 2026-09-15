#!/bin/bash
set -e
echo "[1/3] flutter pub get..."
flutter pub get
echo "[2/3] installing model download deps..."
pip install -r tools/requirements_models.txt
echo "[3/3] downloading offline models..."
python3 tools/download_models.py
echo "Done. Turn Airplane ON and run: flutter run"
