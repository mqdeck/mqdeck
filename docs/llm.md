# Local assistant and models

The local assistant is optional. In the [getting started](getting-started.md)
and [architecture](architecture.md) drawings it is the dotted path from the API
to the local model. Inventory, Worker collection, reports, and Queue Watch work
with `MQDECK_LLM_ENABLED=false` or with no model installed.

When it is enabled, inference runs on the API host, or on an
OpenAI-compatible endpoint you configure. Collected broker data is sent only to
that endpoint, and only after an operator asks. The Worker does not load models
and does not call the assistant.

In Web, open a host, collect data, and choose **Show findings**. Rule findings
from the collection are always available. The assistant summary and chat appear
when the model endpoint is ready.

## Choose a mode

Set this in `/etc/mqdeck/api.properties` on Linux as `mqdeck.llm.enabled=auto`, or as the machine environment variable `MQDECK_LLM_ENABLED` for the API service on Windows and in a container. When both are present, the environment variable wins. Restart `mqdeck-api` after any change.

| `MQDECK_LLM_ENABLED` | Behavior |
| --- | --- |
| `auto` (default) | Start the assistant when a model and `llama-server` (or `MQDECK_LLM_BASE_URL`) are available. If they are missing, the API still starts and diagnostics keep working. |
| `true` | Require a working model endpoint. The API process exits if the model or server cannot start. |
| `false` | Do not start a local server and do not call an external endpoint. |

## Option A - GGUF file and `llama-server`

Use this when the API host should run the model itself.

### 1. Install `llama-server`

`llama-server` comes from [llama.cpp releases](https://github.com/ggml-org/llama.cpp/releases).
The API looks for `llama-server` on `PATH`, or at the absolute path in
`MQDECK_LLAMA_SERVER_BIN`.

On a Linux API host:

```bash
LLAMA_TAG=b11351
ARCH=x64   # use arm64 on aarch64 hosts

curl -fL \
  -o /tmp/llama.tar.gz \
  "https://github.com/ggml-org/llama.cpp/releases/download/${LLAMA_TAG}/llama-${LLAMA_TAG}-bin-ubuntu-${ARCH}.tar.gz"

sudo mkdir -p /opt/mqdeck/llm /tmp/llama-extract
sudo tar -xzf /tmp/llama.tar.gz -C /tmp/llama-extract
sudo install -m 0755 "$(find /tmp/llama-extract -type f -name llama-server | head -n 1)" \
  /opt/mqdeck/llm/llama-server
/opt/mqdeck/llm/llama-server --version
```

Check the llama.cpp release page and bump `LLAMA_TAG` when you want a newer
build. The archive above is the CPU build. On an NVIDIA GPU, use the CUDA
build in the next section instead.

On Windows, install `llama-server.exe` where the `MQDeckAPI` service account
can execute it, then set `MQDECK_LLAMA_SERVER_BIN` to that full path.

### 2. Add a GGUF model

Place one or more `*.gguf` files in the model directory. The API reads only
files in that directory. It does not search subdirectories.

```bash
sudo mkdir -p /opt/mqdeck/api/models
sudo curl -fL \
  -o /opt/mqdeck/api/models/SmolLM2-360M-Instruct-Q4_K_M.gguf \
  "https://huggingface.co/bartowski/SmolLM2-360M-Instruct-GGUF/resolve/main/SmolLM2-360M-Instruct-Q4_K_M.gguf"
sudo chown -R mqdeck:mqdeck /opt/mqdeck/api/models
```

Prefer a small instruct GGUF. With `MQDECK_LLM_MODEL` unset, the API prefers
smaller names that look like instruct or chat models. To pin one file, set
`MQDECK_LLM_MODEL` to the file name (`SmolLM2-360M-Instruct-Q4_K_M.gguf`) or to
the name without the `.gguf` suffix. If that name is missing, startup follows
the `MQDECK_LLM_ENABLED` rules above.

The service account (`mqdeck` on Linux) must be able to read the directory and
the files.

### Ubuntu with an NVIDIA GTX 1660

A GTX 1660 is a Turing card with 6 GB of memory. The CPU `llama-server`
package ignores that GPU. `MQDECK_LLM_GPU_LAYERS` defaults to `0`, so a CUDA
binary also stays on the CPU until you set it.

Use a CUDA 12.8 build. That build still runs on this card. Skip the CUDA 13
archives and any model larger than about 3B parameters: a 7B Q4 file plus the
context does not fit in 6 GB.

```bash
sudo apt update
sudo apt install -y nvidia-driver-570
sudo reboot
```

After reboot, `nvidia-smi` must list the GTX 1660 before you continue.

```bash
LLAMA_TAG=b11476

curl -fL -o /tmp/llama-cuda.tar.gz \
  "https://github.com/ggml-org/llama.cpp/releases/download/${LLAMA_TAG}/llama-${LLAMA_TAG}-bin-ubuntu-cuda-12.8-x64.tar.gz"
curl -fL -o /tmp/llama-cudart.tar.gz \
  "https://github.com/ggml-org/llama.cpp/releases/download/${LLAMA_TAG}/cudart-llama-${LLAMA_TAG}-bin-ubuntu-cuda-12.8-x64.tar.gz"

sudo mkdir -p /opt/mqdeck/llm /tmp/llama-extract
sudo rm -rf /tmp/llama-extract/*
sudo tar -xzf /tmp/llama-cuda.tar.gz -C /tmp/llama-extract
sudo tar -xzf /tmp/llama-cudart.tar.gz -C /tmp/llama-extract
sudo find /tmp/llama-extract -type f \( -name 'llama-server' -o -name 'lib*.so*' \) \
  -exec cp -a {} /opt/mqdeck/llm/ \;
sudo chmod 0755 /opt/mqdeck/llm/llama-server
/opt/mqdeck/llm/llama-server --version
```

Download one instruct model that fits, and pin it so a smaller smoke-test file
is not selected automatically:

```bash
sudo mkdir -p /opt/mqdeck/api/models
sudo curl -fL \
  -o /opt/mqdeck/api/models/Qwen2.5-3B-Instruct-Q4_K_M.gguf \
  "https://huggingface.co/bartowski/Qwen2.5-3B-Instruct-GGUF/resolve/main/Qwen2.5-3B-Instruct-Q4_K_M.gguf"
sudo chown -R mqdeck:mqdeck /opt/mqdeck/api/models
```

`/etc/mqdeck/api.properties`:

```properties
mqdeck.llm.enabled=auto
mqdeck.model.dir=/opt/mqdeck/api/models
mqdeck.llm.model=Qwen2.5-3B-Instruct-Q4_K_M.gguf
mqdeck.llama.server.bin=/opt/mqdeck/llm/llama-server
mqdeck.llm.gpu.layers=99
mqdeck.llm.context=4096
```

`99` asks `llama-server` to put every layer on the GPU. Keep the context at
`4096` on this card. The `mqdeck` service user must be allowed to open the
NVIDIA devices:

```bash
sudo usermod -aG video,render mqdeck
sudo systemctl restart mqdeck-api
nvidia-smi
curl -s http://127.0.0.1:8080/api/v1/ai/status
```

While the assistant is answering, `nvidia-smi` should show `llama-server`
using memory on the GTX 1660. If the process is missing and the API reports
that the server exited, the usual cause is a driver older than the CUDA 12.8
build, or the service user not being in `video` and `render`. Fix that and
restart the API. Do not switch this host to a 7B model to worker around it.

### 3. Point the API at them

Linux `/etc/mqdeck/api.properties`:

```properties
mqdeck.llm.enabled=auto
mqdeck.model.dir=/opt/mqdeck/api/models
mqdeck.llama.server.bin=/opt/mqdeck/llm/llama-server
# mqdeck.llm.model=SmolLM2-360M-Instruct-Q4_K_M.gguf
```

Windows (Administrator PowerShell), then restart `MQDeckAPI`:

```powershell
[Environment]::SetEnvironmentVariable("MQDECK_LLM_ENABLED", "auto", "Machine")
[Environment]::SetEnvironmentVariable("MQDECK_MODEL_DIR", "C:\ProgramData\MQDeck\models", "Machine")
[Environment]::SetEnvironmentVariable("MQDECK_LLAMA_SERVER_BIN", "C:\Program Files\llama\llama-server.exe", "Machine")
Restart-Service MQDeckAPI
```

Create `C:\ProgramData\MQDeck\models` and copy the `.gguf` file there before
the restart. Adjust the `llama-server.exe` path to the binary you installed.

### 4. Check readiness

```bash
sudo systemctl restart mqdeck-api
curl -s http://127.0.0.1:8080/api/v1/ai/status
```

A ready local server reports `"ready": true`, `"provider": "llama-server"`, and
lists discovered files under `"models"`. The active file has `"active": true`.

If `"ready"` is false, read `"message"`. Typical cases:

- `no .gguf models found` - `MQDECK_MODEL_DIR` is empty, wrong, or not readable by the service.
- `llama-server is not on PATH` - set `MQDECK_LLAMA_SERVER_BIN` to the absolute binary path.
- `preferred model ... was not found` - `MQDECK_LLM_MODEL` does not match a file in the directory.
- startup timeout - the first load can be slow. Raise `MQDECK_LLM_STARTUP_TIMEOUT` (default `90s`).

## Option B - existing OpenAI-compatible endpoint

Use this when another service already serves the model. Do not install
`llama-server` or download a GGUF for MQDeck.

```properties
mqdeck.llm.enabled=auto
mqdeck.llm.base.url=http://127.0.0.1:8081/v1
# mqdeck.llm.model=name-expected-by-that-endpoint
```

In a container, set `MQDECK_LLM_ENABLED` and `MQDECK_LLM_BASE_URL` instead.

`MQDECK_LLM_BASE_URL` is the base URL, including the `/v1` prefix when the
server uses the OpenAI path layout. The API waits until that endpoint answers
during startup (`MQDECK_LLM_STARTUP_TIMEOUT`). Status then reports
`"provider": "openai-compatible"`.

Keep this URL on a network the API host can reach. Do not point it at a public
service if collected broker details must stay on premises.

## Environment reference

| Variable | Default | Purpose |
| --- | --- | --- |
| `MQDECK_LLM_ENABLED` | `auto` | `auto`, `true`, or `false` |
| `MQDECK_MODEL_DIR` | `./models` | Directory of `*.gguf` files. Set an absolute path in the service. |
| `MQDECK_LLM_MODEL` | empty | File name to load. Empty uses the automatic preference. |
| `MQDECK_LLAMA_SERVER_BIN` | `llama-server` | Binary name on `PATH`, or an absolute path. |
| `MQDECK_LLM_BASE_URL` | empty | External OpenAI-compatible base URL. Skips the local `llama-server` process. |
| `MQDECK_LLM_HOST` | `127.0.0.1` | Bind address for the API-managed `llama-server`. |
| `MQDECK_LLM_PORT` | `18080` | Loopback port for that process. |
| `MQDECK_LLM_CONTEXT` | `4096` | Context size passed to `llama-server`. |
| `MQDECK_LLM_GPU_LAYERS` | `0` | GPU layers (`-ngl`) when the binary supports them. `0` keeps the model on CPU. |
| `MQDECK_LLM_CHAT_TEMPLATE` | empty | Optional `--chat-template` name. Empty uses the model's Jinja template. |
| `MQDECK_LLM_STARTUP_TIMEOUT` | `90s` | How long the API waits for the endpoint to become ready. |
| `MQDECK_LLM_REQUEST_TIMEOUT` | `90s` | Timeout for one assistant request. |

Leave `MQDECK_LLM_HOST` on loopback unless you have a reason to expose
`llama-server`. The operator UI talks to the MQDeck API, not to that port.
