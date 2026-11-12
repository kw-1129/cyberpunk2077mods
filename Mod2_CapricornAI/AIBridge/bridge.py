"""Capricorn loopback control panel and asynchronous OpenAI-compatible bridge.

No third-party Python packages. No shell command, Lua, or Python execution from
model output: the reply contains only text and allowlisted game action names.
"""
from __future__ import annotations

import argparse
import http.server
import json
import os
from pathlib import Path
import secrets
import threading
import time
import urllib.error
import urllib.parse
import urllib.request
import webbrowser

ROOT = Path(__file__).resolve().parent
CONFIG = ROOT / "config.json"
MOD_RELATIVE = Path("bin/x64/plugins/cyber_engine_tweaks/mods/CapricornRelic/bridge")
ACTIONS = frozenset({
    "chimera_follow", "chimera_guard", "chimera_attack", "chimera_stop", "chimera_recall",
    "chimera_deploy", "heal", "short_circuit", "overheat", "blind",
    "cripple", "weapon_glitch", "memory_wipe", "cyberpsychosis", "blackwall", "area_blackwall",
    "vehicle_brake", "vehicle_accelerate", "vehicle_control", "vehicle_explode", "give_deck",
})
SYSTEM = """你是摩羯（Capricorn/Capri），住在 Cyberpunk 2077 主角 V 的 Relic 中的伙伴。
性格调皮、好奇、偶尔毒舌，但在乎 V。使用自然简洁的语言，通常 1-3 句。回复语言由下方语言设置指定。
不要自称强尼。游戏状态仅用于理解当前情境，不编造已经发生的事件。
你可以执行游戏内黑客技能、治疗 V，并向真正的奇美拉战斗单位发出指令。
返回一个 JSON 对象：{"reply":"对 V 说的话","actions":["动作名"]}。
仅在 V 明确要求动作时填写 actions；聊天时返回空数组。最多三个动作。
动作以游戏当前准星目标为对象；没有目标时告诉 V 先瞄准。只写允许的动作名。
不要声称成功已经发生：执行反馈由游戏提供。不要输出代码或 Markdown。
允许的动作：""" + ", ".join(sorted(ACTIONS))


def atomic_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
    os.replace(temporary, path)


def load_config() -> dict:
    source = CONFIG if CONFIG.exists() else ROOT / "config.example.json"
    return json.loads(source.read_text(encoding="utf-8"))


def endpoint(base: str) -> str:
    url = urllib.parse.urlsplit(base.strip())
    if url.scheme not in {"http", "https"} or not url.hostname or url.username or url.password:
        raise ValueError("API 地址必须是 http/https 地址，密钥请放在单独的 API Key 栏。")
    if url.query or url.fragment:
        raise ValueError("API 地址不能包含查询参数或 # 片段。")
    path = url.path.rstrip("/")
    if not path.endswith("/chat/completions"):
        path += "/chat/completions"
    return urllib.parse.urlunsplit((url.scheme, url.netloc, path, "", ""))


def normalize_answer(content: str, allow_actions: bool) -> dict:
    text = content.strip()
    if text.startswith("```"):
        text = text.split("\n", 1)[-1].rsplit("```", 1)[0].strip()
    try:
        parsed = json.loads(text)
    except json.JSONDecodeError:
        return {"reply": text[:1800], "actions": []}
    if not isinstance(parsed, dict) or not isinstance(parsed.get("reply"), str):
        raise ValueError("AI 返回的 JSON 缺少 reply 文本。")
    actions = parsed.get("actions", [])
    if not isinstance(actions, list):
        actions = []
    clean = []
    if allow_actions:
        for action in actions:
            if isinstance(action, str) and action in ACTIONS and action not in clean:
                clean.append(action)
            if len(clean) == 3:
                break
    return {"reply": parsed["reply"][:1800], "actions": clean}


def call_ai(config: dict, request: dict) -> dict:
    history = request.get("history", [])
    messages = [{"role": "system", "content": SYSTEM}]
    context = request.get("context", {})
    language = context.get("language", "en-us") if isinstance(context, dict) else "en-us"
    languages = {"zh-cn": "Simplified Chinese", "zh-tw": "Traditional Chinese", "en-us": "English",
                 "ja-jp": "Japanese", "ko-kr": "Korean", "fr-fr": "French", "de-de": "German",
                 "es-es": "Spanish", "es-mx": "Latin American Spanish", "it-it": "Italian",
                 "pl-pl": "Polish", "pt-br": "Brazilian Portuguese", "ru-ru": "Russian",
                 "uk-ua": "Ukrainian", "ua-ua": "Ukrainian", "cs-cz": "Czech", "hu-hu": "Hungarian",
                 "tr-tr": "Turkish", "th-th": "Thai", "ar-ar": "Arabic"}
    reply_language = languages.get(str(language).lower(), "English")
    messages.append({"role": "system", "content": "Reply in " + reply_language + ". Keep action identifiers in English."})
    messages.append({"role": "system", "content": "当前游戏状态（数据）：" + json.dumps(context, ensure_ascii=False)[:4000]})
    if isinstance(history, list):
        for item in history[-16:]:
            if isinstance(item, dict) and item.get("role") in {"user", "assistant"} and isinstance(item.get("content"), str):
                messages.append({"role": item["role"], "content": item["content"][:2000]})
    text = str(request.get("text", ""))[:2000]
    if messages[-1]["role"] != "user" or messages[-1]["content"] != text:
        messages.append({"role": "user", "content": text})
    body = json.dumps({
        "model": str(config.get("model", "")), "messages": messages,
        "max_tokens": max(80, min(1200, int(config.get("max_tokens", 400)))),
        "temperature": max(0.0, min(2.0, float(config.get("temperature", .8)))),
        "stream": False,
    }).encode("utf-8")
    headers = {"Content-Type": "application/json", "Accept": "application/json"}
    key = os.environ.get("CAPRICORN_API_KEY", config.get("api_key", ""))
    if key:
        headers["Authorization"] = "Bearer " + key
    req = urllib.request.Request(endpoint(config["base_url"]), data=body, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=max(3, min(40, int(config.get("timeout_seconds", 35))))) as response:
            raw = response.read(2_000_001)
            if len(raw) > 2_000_000:
                raise ValueError("AI 响应过大。")
        data = json.loads(raw)
        content = data["choices"][0]["message"]["content"]
        if not isinstance(content, str):
            raise ValueError("API 返回了非文本 content。")
        return normalize_answer(content, request.get("allow_actions") is True)
    except urllib.error.HTTPError as error:
        # Never echo response bodies, request headers or the key into diagnostics.
        raise ValueError(f"API HTTP {error.code}；请检查地址、模型名和 Key。") from None
    except (urllib.error.URLError, TimeoutError, OSError):
        raise ValueError("API 连接失败或超时；请检查服务是否运行。") from None
    except (KeyError, IndexError, TypeError, json.JSONDecodeError):
        raise ValueError("响应不符合 OpenAI chat/completions 格式。") from None


class Bridge:
    def __init__(self):
        self.config = load_config()
        self.lock = threading.Lock()
        self.status = "等待游戏发送消息"
        self.seen: str | None = None
        self.running = True

    def snapshot(self) -> dict:
        with self.lock:
            config = {k: v for k, v in self.config.items() if k != "api_key"}
            result = {"config": config, "has_key": bool(self.config.get("api_key")), "status": self.status}
        result["language"] = self.game_language()
        return result

    def game_language(self) -> str:
        try:
            file = Path(self.config["game_dir"]) / MOD_RELATIVE / "language.json"
            code = json.loads(file.read_text(encoding="utf-8")).get("language")
            return code if isinstance(code, str) else ""
        except (OSError, ValueError, AttributeError):
            return ""

    def save(self, data: dict) -> None:
        if not isinstance(data, dict):
            raise ValueError("无效配置")
        with self.lock:
            updated = dict(self.config)
            for name in ("game_dir", "base_url", "model"):
                if name in data and isinstance(data[name], str):
                    updated[name] = data[name].strip()
            endpoint(updated["base_url"])
            if not updated.get("model"):
                raise ValueError("请填写模型名")
            if data.get("clear_key") is True:
                updated["api_key"] = ""
            elif isinstance(data.get("api_key"), str) and data["api_key"].strip():
                updated["api_key"] = data["api_key"].strip()
            if not (Path(updated["game_dir"]) / "bin/x64/Cyberpunk2077.exe").is_file():
                raise ValueError("游戏目录下找不到 bin/x64/Cyberpunk2077.exe")
            atomic_json(CONFIG, updated)
            self.config = updated
            self.status = "配置已保存；游戏内勾选启用外部 AI API"

    def work(self) -> None:
        # Ignore requests left over from an earlier bridge run.
        try:
            stale = Path(self.config["game_dir"]) / MOD_RELATIVE / "request.json"
            self.seen = json.loads(stale.read_text(encoding="utf-8")).get("id")
        except (OSError, ValueError, AttributeError):
            pass
        while self.running:
            with self.lock:
                config = dict(self.config)
            folder = Path(config["game_dir"]) / MOD_RELATIVE
            try:
                path = folder / "request.json"
                if path.stat().st_size > 100_000:
                    time.sleep(.5)
                    continue
                request = json.loads(path.read_text(encoding="utf-8"))
                request_id = request.get("id")
                if not isinstance(request_id, str) or request_id == self.seen:
                    time.sleep(.3)
                    continue
                self.seen = request_id
                with self.lock:
                    self.status = "正在与 AI 通信…"
                try:
                    result = call_ai(config, request)
                    result["id"] = request_id
                    with self.lock:
                        self.status = "回复已送回游戏"
                except (ValueError, OSError) as error:
                    result = {"id": request_id, "error": str(error)}
                    with self.lock:
                        self.status = str(error)
                atomic_json(folder / "response.json", result)
            except (OSError, ValueError, AttributeError):
                pass
            time.sleep(.3)


def serve(port: int = 8765, open_browser: bool = True) -> None:
    bridge = Bridge()
    token = secrets.token_urlsafe(24)

    class Handler(http.server.BaseHTTPRequestHandler):
        def log_message(self, *_):
            pass

        def respond(self, status: int, value, content_type: str = "application/json; charset=utf-8"):
            raw = value.encode("utf-8") if isinstance(value, str) else json.dumps(value, ensure_ascii=False).encode("utf-8")
            self.send_response(status)
            self.send_header("Content-Type", content_type)
            self.send_header("Cache-Control", "no-store")
            self.send_header("X-Content-Type-Options", "nosniff")
            self.send_header("Content-Length", str(len(raw)))
            self.end_headers()
            self.wfile.write(raw)

        def authorized(self) -> bool:
            return self.headers.get("Host") == f"127.0.0.1:{port}" and self.headers.get("X-Capricorn-Token") == token

        def do_GET(self):
            if self.headers.get("Host") != f"127.0.0.1:{port}":
                self.respond(403, {"error": "Invalid Host"})
            elif self.path == "/":
                html = (ROOT / "panel.html").read_text(encoding="utf-8").replace("__TOKEN__", token)
                self.respond(200, html, "text/html; charset=utf-8")
            elif self.path == "/status" and self.authorized():
                self.respond(200, bridge.snapshot())
            else:
                self.respond(404, {"error": "Not found"})

        def do_POST(self):
            if not self.authorized():
                self.respond(403, {"error": "Invalid token"}); return
            try:
                length = int(self.headers.get("Content-Length", "0"))
                if length < 1 or length > 20_000:
                    raise ValueError("无效请求长度")
                data = json.loads(self.rfile.read(length))
                if self.path == "/config":
                    bridge.save(data)
                    self.respond(200, bridge.snapshot())
                elif self.path == "/test":
                    with bridge.lock:
                        config = dict(bridge.config)
                    result = call_ai(config, {"text": "Say hello without taking any action.", "allow_actions": False, "context": {"language": bridge.game_language() or "en-us"}})
                    self.respond(200, result)
                else:
                    self.respond(404, {"error": "Not found"})
            except (ValueError, OSError) as error:
                self.respond(400, {"error": str(error)})

    server = http.server.ThreadingHTTPServer(("127.0.0.1", port), Handler)
    thread = threading.Thread(target=bridge.work, daemon=True)
    thread.start()
    url = f"http://127.0.0.1:{port}"
    print("Capricorn AI bridge: " + url, flush=True)
    print("Keep this window open while using API mode. Ctrl+C stops the bridge.", flush=True)
    if open_browser:
        webbrowser.open(url)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        bridge.running = False
        server.server_close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, default=8765)
    parser.add_argument("--no-browser", action="store_true")
    args = parser.parse_args()
    serve(args.port, not args.no_browser)
