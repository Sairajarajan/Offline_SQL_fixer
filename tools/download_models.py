"""
Offline SQL Fixer - one-time model downloader.
Run WITH internet once in lab, then go fully offline (airplane ON).

Downloads (all <=500M, all local inference, no API keys):
 1. distilbert-base-uncased 66M -> ONNX (NER: error code + faulty word)
 2. sentence-transformers/all-MiniLM-L6-v2 22M -> TFLite/ONNX (fuzzy match)
 3. google/flan-t5-small 80M -> ONNX (simplify only, never generates SQL)
 4. Helsinki-NLP/opus-mt-en-ta ~75M -> ONNX (EN->TA text only)

Usage:
  pip install -r tools/requirements_models.txt
  python tools/download_models.py

Output: assets/models/
"""
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MODELS = ROOT / "assets" / "models"
MODELS.mkdir(parents=True, exist_ok=True)

def log(m): print(f"[setup] {m}")

def try_optimum_exports():
    try:
        from optimum.onnxruntime import ORTModelForSequenceClassification, ORTModelForSeq2SeqLM
        from transformers import AutoTokenizer
        return True
    except Exception as e:
        log(f"optimum/transformers not installed: {e}")
        return False

def export_distilbert():
    log("1/4 distilbert-base-uncased 66M (Apache-2.0)...")
    try:
        from optimum.onnxruntime import ORTModelForTokenClassification
        from transformers import AutoTokenizer
        m = ORTModelForTokenClassification.from_pretrained("distilbert-base-uncased", export=True)
        m.save_pretrained(MODELS / "distilbert_ner_onnx")
        AutoTokenizer.from_pretrained("distilbert-base-uncased").save_pretrained(MODELS / "distilbert_ner_onnx")
        log("saved distilbert_ner_onnx/ (use as distilbert_ner.onnx)")
    except Exception as e:
        log(f"distilbert export skipped: {e}")
        log("manual: https://huggingface.co/distilbert-base-uncased")

def export_minilm():
    log("2/4 all-MiniLM-L6-v2 22M (Apache-2.0)...")
    try:
        from sentence_transformers import SentenceTransformer
        model = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")
        log("loaded MiniLM. Export to ONNX/TFLite:")
        log("  optimum-cli export onnx --model sentence-transformers/all-MiniLM-L6-v2 assets/models/minilm_onnx/")
        log("  then convert to .tflite with ai-edge-torch if needed. App falls back to TF-IDF if file missing.")
        # save vocab for fallback check
        (MODELS / "minilm_info.txt").write_text("sentence-transformers/all-MiniLM-L6-v2 22M Apache-2.0\n", encoding="utf-8")
    except Exception as e:
        log(f"minilm skipped: {e}")

def export_flant5():
    log("3/4 google/flan-t5-small 80M (Apache-2.0)...")
    try:
        from optimum.onnxruntime import ORTModelForSeq2SeqLM
        from transformers import AutoTokenizer
        m = ORTModelForSeq2SeqLM.from_pretrained("google/flan-t5-small", export=True)
        m.save_pretrained(MODELS / "flan_t5_small_onnx")
        AutoTokenizer.from_pretrained("google/flan-t5-small").save_pretrained(MODELS / "flan_t5_small_onnx")
        log("saved flan_t5_small_onnx/")
    except Exception as e:
        log(f"flan-t5 export skipped: {e}")

def export_opus():
    log("4/4 Helsinki-NLP/opus-mt-en-ta ~75M (CC-BY-4.0 Marian)...")
    try:
        from optimum.onnxruntime import ORTModelForSeq2SeqLM
        from transformers import AutoTokenizer
        m = ORTModelForSeq2SeqLM.from_pretrained("Helsinki-NLP/opus-mt-en-ta", export=True)
        m.save_pretrained(MODELS / "opus_mt_en_ta_onnx")
        AutoTokenizer.from_pretrained("Helsinki-NLP/opus-mt-en-ta").save_pretrained(MODELS / "opus_mt_en_ta_onnx")
        log("saved opus_mt_en_ta_onnx/")
    except Exception as e:
        log(f"opus export skipped: {e}")

if __name__ == "__main__":
    log(f"target: {MODELS}")
    export_distilbert()
    export_minilm()
    export_flant5()
    export_opus()
    log("Done. App runs 100% offline after this. If exports failed, app still works via built-in offline fallback (regex + local JSON).")
    log("Verify: airplane ON -> flutter run -> Try Sample 1064 -> EN/TA -> Speak.")
