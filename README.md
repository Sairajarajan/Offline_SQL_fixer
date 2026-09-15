This project was submitted to the ryze.ai hackathon by [YOUR NAME].

Offline SQL Error Fixer explains pasted MySQL errors in simple English/Tamil and shows a safe fix from a local list, fully offline for DB labs with no internet.

How to run:
```bash
flutter pub get
flutter run
```

Models (all <=500M params, all run local via onnxruntime / tflite_flutter, no cloud):

| Model | Params | Used for | Runtime | License | Local path |
|---|---|---|---|---|---|
| distilbert-base-uncased | 66M | error-code + faulty-word extraction (NER) | onnxruntime | Apache-2.0 | assets/models/distilbert_ner.onnx |
| sentence-transformers/all-MiniLM-L6-v2 | 22M | fuzzy match error text to local DB (cosine >0.7) | tflite_flutter | Apache-2.0 | assets/models/minilm_l6v2.tflite |
| google/flan-t5-small | 80M | simplify matched entry to Why + Fix 1-2-3 simple English only, never generates new SQL | onnxruntime | Apache-2.0 | assets/models/flan_t5_small.onnx |
| Helsinki-NLP/opus-mt-en-ta | ~75M | EN->TA text only for toggle | onnxruntime | CC-BY-4.0 (MarianMT) | assets/models/opus_mt_en_ta.onnx |

No OpenAI, Anthropic, Google AI, HuggingFace Inference API, or Ollama cloud. Non-AI packages (flutter_tts offline engine, hive) allowed.

Offline airplane test (demo for judges):
1. Run `python tools/download_models.py` once WITH internet to fill `assets/models/` (or app works without models via built-in regex fallback).
2. `flutter run` on device.
3. Turn Airplane Mode ON.
4. Home -> Fix Error -> Try Sample -> pick `1064 Syntax` -> Fix.
5. See Why + Fix EN -> toggle top English | தமிழ் -> Speak (speaks Fix steps only, en-IN/ta-IN offline).
6. Banner must always show "Offline - code never left device".

Safety: Helper only, verify with faculty. Does not run DELETE/DROP. Never auto-executes SQL. If cosine <0.7 or code unknown shows "Not in offline list - ask faculty" / "Paste more lines", never hallucinates a fix.
