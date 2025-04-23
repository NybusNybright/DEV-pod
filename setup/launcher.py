import subprocess
import os
import signal
import webbrowser
from flask import Flask, render_template_string, redirect, url_for, jsonify, request
from threading import Timer
from datetime import datetime
import sys

log_path = "/workspace/logs"
os.makedirs(log_path, exist_ok=True)

log_file = os.path.join(log_path, "launcher.log")
sys.stdout = open(log_file, "a")
sys.stderr = sys.stdout

print(f"\n🕓 Launcher started at {datetime.now()}\n")


app = Flask(__name__, static_folder='static')

processes = {
    "comfy": None,
    "sd-webui": None  # Changed 'forge' to 'sd-webui'
}

ports = {
    "comfy": 8188,
    "sd-webui": 6767,  # Changed from 'forge' to 'sd-webui'
    "launcher": 5555
}

html_template = '''
<!DOCTYPE html>
<html>
<head>
    <title>WebUI Launcher</title>
    <link rel="icon" href="/static/favicon.png" type="image/png">
    <style>
        body { font-family: sans-serif; text-align: center; margin-top: 30px; background-color: #111; color: white; }
        button {
            padding: 15px 30px;
            margin: 10px;
            font-size: 16px;
            border: none;
            cursor: pointer;
            border-radius: 8px;
            min-width: 150px;
        }
        .running { background-color: #4CAF50; color: white; }
        .stopped { background-color: #888; color: white; }
        .terminate { background-color: #f44336; color: white; }
        .open { background-color: #2196F3; color: white; }
        .refresh { background-color: #ff9800; color: white; }
        pre { background: #222; padding: 10px; border-radius: 8px; text-align: left; display: inline-block; white-space: pre-wrap; max-width: 80%%; overflow-wrap: break-word; }
        a { text-decoration: none; }
    </style>
</head>
<body>
    <h1>WebUI Launcher 🚀</h1>
    <p><strong>RunPod ID:</strong> {{ RUNPOD_ID }}</p>

    {% for key in ["comfy", "sd-webui"] %}  <!-- Changed 'forge' to 'sd-webui' -->
        <form action="/launch/{{ key }}" method="post" style="display:inline;">
            <button class="{{ 'running' if running[key] else 'stopped' }}">Launch {{ key.title() }}</button>
        </form>
        <form action="/terminate/{{ key }}" method="post" style="display:inline;">
            <button class="terminate">Terminate {{ key.title() }}</button>
        </form>
        <button class="open" onclick="window.open('https://{{ RUNPOD_ID }}-{{ ports[key] }}.proxy.runpod.net', '_blank')">
            Open {{ key.title() }}
        </button>
        <br><br>
    {% endfor %}

    <form action="/refresh_ports" method="get" style="display:inline;">
        <button class="refresh">Refresh Ports</button>
    </form>
    <form action="/reset_ports" method="post" style="display:inline;">
        <button class="terminate">Reset Ports</button>
    </form>

    <h2>Open Ports</h2>
    <pre>{{ open_ports }}</pre>
</body>
</html>
'''

def get_pod_id():
    return os.environ.get("RUNPOD_POD_ID") or os.uname()[1].split("-")[0]

def kill_if_running(name):
    port = ports[name]
    try:
        if processes[name] and processes[name].poll() is None:
            os.killpg(os.getpgid(processes[name].pid), signal.SIGTERM)
            print(f"✅ Killed {name} (PID {processes[name].pid})")
        else:
            output = subprocess.check_output(["lsof", "-i", f":{port}"], stderr=subprocess.DEVNULL).decode()
            for line in output.splitlines()[1:]:
                pid = int(line.split()[1])
                print(f"🔪 Killing fallback {name} PID: {pid}")
                os.killpg(os.getpgid(pid), signal.SIGTERM)
    except Exception as e:
        print(f"⚠️ Could not terminate {name}: {e}")
    processes[name] = None

def get_open_ports():
    try:
        output = subprocess.check_output(["ss", "-tuln"], stderr=subprocess.DEVNULL).decode()
        filtered = []
        for line in output.splitlines():
            if any(f":{p} " in line for p in ports.values()):
                parts = line.split()
                port = parts[4] if len(parts) > 4 else "?"
                pid_info = subprocess.getoutput(f"lsof -i :{port.split(':')[-1]} -sTCP:LISTEN -P -n | awk 'NR>1 {{print $2, $1}}'")
                for pid_line in pid_info.splitlines():
                    pid, cmd = pid_line.strip().split()[:2]
                    filtered.append(f"PID {pid} | {port} | {cmd}")
        return "\n".join(filtered) if filtered else "No relevant open ports."
    except Exception as e:
        return f"Error checking ports: {e}"

@app.route("/")
def index():
    pod_id = get_pod_id()
    print("🧠 Rendering WebUI with pod_id:", pod_id)
    open_port_text = get_open_ports()
    running = {
        "comfy": str(ports['comfy']) in open_port_text,
        "sd-webui": str(ports['sd-webui']) in open_port_text  # Changed 'forge' to 'sd-webui'
    }
    return render_template_string(
        html_template,
        processes=processes,
        ports=ports,
        open_ports=open_port_text,
        RUNPOD_ID=pod_id,
        running=running
    )

@app.route("/refresh_ports")
def refresh_ports():
    return redirect(url_for("index"))

@app.route("/reset_ports", methods=["POST"])
def reset_ports():
    for port in [8188, 6767, 5555]:
        try:
            subprocess.run(["fuser", "-k", f"{port}/tcp"], check=False)
            print(f"🔪 Reset port {port}")
        except Exception as e:
            print(f"⚠️ Failed to reset port {port}: {e}")
    return redirect(url_for("index"))

@app.route("/launch/<name>", methods=["POST"])
def launch(name):
    if name not in processes:
        return redirect(url_for("index"))

    kill_if_running(name)

    try:
        # Comfy
        if name == "comfy":
            cmd = [
                "/workspace/venv/bin/python",
                "/workspace/ComfyUI/main.py",
                "--listen",
                "--port", str(ports["comfy"]),
                "--cuda-malloc"
            ]
            logfile = open("/workspace/logs/comfy.log", "a")
            processes[name] = subprocess.Popen(cmd, preexec_fn=os.setsid, stdout=logfile, stderr=logfile)

        # SD-WebUI
        elif name == "sd-webui":
            cmd = [
                "/workspace/venv/bin/python",
                "/workspace/sd-webui/webui.py",
                "--listen",
                "--port", str(ports["sd-webui"]),
                "--cuda-malloc"
            ]
            logfile = open("/workspace/logs/sd-webui.log", "a")
            processes[name] = subprocess.Popen(cmd, preexec_fn=os.setsid, stdout=logfile, stderr=logfile)


        print(f"🚀 Launching {name}: {' '.join(cmd)}")
        processes[name] = subprocess.Popen(
            cmd,
            preexec_fn=os.setsid
        )

    except Exception as e:
        print(f"❌ Failed to launch {name}: {e}")
        processes[name] = None

    return redirect(url_for("index"))

@app.route("/terminate/<name>", methods=["POST"])
def terminate(name):
    if name in processes:
        print(f"⛔ Terminating {name}...")
        kill_if_running(name)
    else:
        print(f"⚠️ Unknown process: {name}")
    return redirect(url_for("index"))

if __name__ == "__main__":
    Timer(1.0, lambda: webbrowser.open_new("http://localhost:5555")).start()
    app.run(host="0.0.0.0", port=5555, debug=True, use_reloader=False)
