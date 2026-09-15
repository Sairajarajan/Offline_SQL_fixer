# Setup Instructions — Offline SQL Error Fixer

Follow these steps in order. You only need internet once (for packages + models).
After that the app runs 100% offline (airplane mode ON).

## 1. Prerequisites

| Need | Check |
|---|---|
| Flutter SDK 3.32+ (this repo used 3.44.6) | `flutter --version` |
| Android emulator or device (API 30+) | `flutter devices` |
| Python 3.10+ (only for downloading AI models) | `python --version` |
| Git | `git --version` |

> Use the **Android emulator**, not Chrome. `flutter_tts` offline voices,
> Hive and the on-device runtimes are Android-focused.

## 2. Clone & install

```bash
git clone https://github.com/Sairajarajan/Offline_SQL_fixer.git
cd Offline_SQL_fixer
flutter pub get
```

If `flutter run` says **"No supported devices connected"** or
**"AndroidManifest.xml could not be found"**, generate the platform folders:

```bash
flutter create . --project-name offline_sql_fixer --org com.ryzehack.sqlfixer
flutter pub get
```

## 3. Download AI models (one time, optional)

The app works without these (built-in regex + TF-IDF fallback),
but real models give better matching:

```bash
pip install -r tools/requirements_models.txt
python tools/download_models.py
```

| Model | Params | File |
|---|---|---|
| distilbert-base-uncased | 66M | `assets/models/distilbert_ner_onnx/` |
| all-MiniLM-L6-v2 | 22M | `assets/models/minilm_onnx/` |
| flan-t5-small | 80M | `assets/models/flan_t5_small_onnx/` |

Models are git-ignored on purpose (too large for GitHub).

## 4. Run

```bash
# from the project root (NOT from lib/)
flutter run -d emulator-5554
```

Demo flow: **Fix Error → Try Sample 1064 → Fix My Error → Why + Fix → Speak/Stop.**

## 5. Offline test (must pass before submission)

1. Install the APK on the device once (step 4).
2. Turn **Airplane Mode ON**.
3. Kill and reopen the app.
4. Fix Error → Try Sample → Fix → Speak → Save → My Fixes.
5. Banner must always read **"Offline - code never left device"**.

## 6. Regenerate the logo (optional)

```bash
python tools/make_logo.py
dart run flutter_launcher_icons
```

Source: `tools/make_logo.py` → `assets/logo/app_icon.png`.

## 7. Troubleshooting

| Error | Fix |
|---|---|
| `No supported devices connected` | Run `flutter create .` (step 2), run from project root |
| `AndroidManifest.xml could not be found` | Same as above |
| `UnmodifiableUint8ListView` (tflite) | Already fixed: `tflite_flutter` removed, pure-Dart matching used |
| `JVM Target Compatibility` (Kotlin) | Same as above — no Kotlin plugin left except `flutter_tts` |
| `flutter_tts ... KGP` warning | Harmless warning, build still succeeds |
| `opus-mt-en-ta 401` during model download | Ignore — Tamil toggle was removed, that model is unused |
| `MyApp isn't a class` in tests | Already fixed — test uses `OfflineSqlFixerApp` |

## 8. Push changes

```bash
git add -A
git commit -m "Describe your change"
git push
```
