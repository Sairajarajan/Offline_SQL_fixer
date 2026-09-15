# Resources needed & used

All offline. Code never leaves device. No API keys, no login, no cloud.

## 1. Flutter packages (pubspec.yaml)
| Package | Why |
|---|---|
| flutter_tts | Offline device TTS for Speak (Fix steps only), en-IN/ta-IN |
| hive + hive_flutter | Offline saved fixes (My Fixes), no login |
| shared_preferences | Language toggle EN/TA persistence |
| path_provider | Hive storage path |
| onnxruntime | Run distilbert 66M, flan-t5-small 80M, opus-mt-en-ta 75M locally |
| tflite_flutter | Run MiniLM 22M locally |
| clipboard / share_plus | Copy Fix button (non-AI, allowed) |

## 2. AI models (all <=500M, all local, all in assets/models/)
| Model | Params | Task | License | Source |
|---|---|---|---|---|
| distilbert-base-uncased | 66M | Extract error code + faulty word | Apache-2.0 | https://huggingface.co/distilbert-base-uncased |
| sentence-transformers/all-MiniLM-L6-v2 | 22M | Fuzzy match error -> local JSON (cosine >0.7) | Apache-2.0 | https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2 |
| google/flan-t5-small | 80M | Simplify matched entry to simple Why + 1-2-3 steps only | Apache-2.0 | https://huggingface.co/google/flan-t5-small |
| Helsinki-NLP/opus-mt-en-ta | ~75M | EN->TA text only | CC-BY-4.0 (MarianMT) | https://huggingface.co/Helsinki-NLP/opus-mt-en-ta |

Download once with internet:
```
pip install -r tools/requirements_models.txt
python tools/download_models.py
REM or double-click tools/setup.bat
```
Fallback: if .onnx/.tflite missing, app still works 100% offline via deterministic Dart fallback (regex NER + TF-IDF cosine + template simplifier + pre-translated JSON Tamil). Judges can demo airplane-ON with zero downloads.

## 3. Local data (hardcoded, no AI generation)
- `assets/data/sql_errors.json` - 40 MySQL errors: code, pattern, why_simple_en, fix_steps_en[3], why_ta, fix_ta[3]. Fix ALWAYS comes from here. If cosine <0.7 -> "Not in offline list - ask faculty".
- `assets/samples/sample_1064.txt, sample_1054.txt, sample_1062.txt` - 1-click judge samples (ERROR + ---QUERY--- + SQL).
- `assets/models/.gitkeep` - model folder placeholder.

## 4. System voices (offline)
- Android: Google TTS / Samsung TTS with en-IN + ta-IN packs pre-installed (Settings -> Language -> Text-to-speech -> Install voice data while online once).
- No network TTS used. `flutter_tts` set to offline-only, speaks Fix steps only.

## 5. What is NOT used (banned)
OpenAI, Anthropic, Google AI Studio, HuggingFace Inference API, Ollama cloud, Firebase, any login, auto-run SQL, chatbot.
