from __future__ import annotations

import argparse
import json
import re
from datetime import datetime
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


ROOT = Path(__file__).resolve().parent
DATA_DIR = ROOT / "SilviForTANITA" / "data"
EXPORT_DIR = DATA_DIR / "exports"
STATE_FILE = DATA_DIR / "silvifortanita_state.json"


def ensure_dirs() -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    EXPORT_DIR.mkdir(parents=True, exist_ok=True)


def json_bytes(payload: object, status: int = 200) -> tuple[int, bytes]:
    return status, json.dumps(payload, ensure_ascii=False, indent=2).encode("utf-8")


def safe_filename(name: str, suffix: str) -> str:
    base = Path(name or "").name
    base = re.sub(r"[^A-Za-z0-9._-]+", "_", base).strip("._")
    if not base:
        stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        base = f"SilviForTANITA_{stamp}{suffix}"
    if not base.lower().endswith(suffix):
        base += suffix
    return base


class SilviHandler(SimpleHTTPRequestHandler):
    server_version = "SilviForTANITA/1.0"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def _send_json(self, payload: object, status: int = 200) -> None:
        code, body = json_bytes(payload, status)
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def _read_json(self) -> object:
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length)
        return json.loads(raw.decode("utf-8"))

    def do_GET(self) -> None:
        if self.path.split("?", 1)[0] == "/api/state":
            ensure_dirs()
            if STATE_FILE.exists():
                self._send_json(
                    {
                        "ok": True,
                        "updatedAt": datetime.fromtimestamp(STATE_FILE.stat().st_mtime).isoformat(timespec="seconds"),
                        "state": json.loads(STATE_FILE.read_text(encoding="utf-8")),
                    }
                )
            else:
                self._send_json({"ok": False, "state": None})
            return
        super().do_GET()

    def do_POST(self) -> None:
        path = self.path.split("?", 1)[0]
        try:
            ensure_dirs()
            payload = self._read_json()
            if path == "/api/state":
                if not isinstance(payload, dict):
                    raise ValueError("El estado debe ser un objeto JSON.")
                STATE_FILE.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
                self._send_json({"ok": True, "path": str(STATE_FILE)})
                return
            if path == "/api/export-csv":
                if not isinstance(payload, dict):
                    raise ValueError("La exportacion debe ser un objeto JSON.")
                filename = safe_filename(str(payload.get("filename", "")), ".csv")
                csv_text = str(payload.get("csv", ""))
                target = EXPORT_DIR / filename
                target.write_text(csv_text, encoding="utf-8-sig")
                self._send_json({"ok": True, "path": str(target)})
                return
            self._send_json({"ok": False, "error": "Ruta API no encontrada."}, 404)
        except Exception as exc:  # noqa: BLE001 - this is a local helper server.
            self._send_json({"ok": False, "error": str(exc)}, 400)


def main() -> None:
    parser = argparse.ArgumentParser(description="Servidor local de SilviForTANITA")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8765)
    args = parser.parse_args()
    ensure_dirs()
    server = ThreadingHTTPServer((args.host, args.port), SilviHandler)
    print(f"SilviForTANITA en http://{args.host}:{args.port}/SilviForTANITA/")
    print(f"Estado persistente: {STATE_FILE}")
    server.serve_forever()


if __name__ == "__main__":
    main()
