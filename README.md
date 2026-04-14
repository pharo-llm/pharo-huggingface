# pharo-huggingface

A complete Hugging Face client for Pharo.

## Install

```smalltalk
Metacello new
    baseline: 'HuggingFace';
    repository: 'github://pharo-llm/pharo-huggingface:main/src';
    load.
```

Groups: `Core`, `Hub`, `Inference`, `Tests`, `default` (= Core + Hub +
Inference), `all` (everything including tests).

## Authentication

The client picks up a token from, in order:

1. `HfConfiguration >> token:` when set explicitly
2. `HF_TOKEN` / `HUGGINGFACE_TOKEN` / `HUGGING_FACE_HUB_TOKEN` env vars
3. `~/.cache/huggingface/token` (written by the official `huggingface-cli login`)

Everything works anonymously for public reads; writes and gated repos need a
token with the appropriate scope.

## Quickstart

```smalltalk
| client api |
client := HfClient default.       "token picked up automatically"
api := client hub.

"List / search"
api listModels: (Dictionary new
    at: 'search' put: 'llama';
    at: 'limit' put: 10;
    yourself).

"Inspect a repo"
(api modelInfo: 'bert-base-uncased') siblings.

"Download a single file (cached on disk, returns a FileReference)"
api downloadFileFrom: 'bert-base-uncased' path: 'config.json'.

"Snapshot a full revision into the cache"
api snapshotDownload: 'bert-base-uncased' type: #model revision: 'main'.

"Create a repo, upload a file, delete it again"
api createRepo: 'me/my-model' type: #model private: true.
api uploadFile: '/tmp/model.safetensors' toRepo: 'me/my-model'.
api deleteRepo: 'me/my-model' type: #model.
```

## Inference

```smalltalk
| chat text |
chat := client inference
    chatCompletion: 'meta-llama/Llama-3-8B-Instruct'
    messages: {
        HfChatMessage system: 'You are a concise assistant.'.
        HfChatMessage user: 'Explain metaclasses in one sentence.' }.
text := client inference firstChoiceTextOf: chat.

client inference
    textGeneration: 'gpt2'
    prompt: 'Once upon a time'
    options: (Dictionary new
        at: 'max_new_tokens' put: 50;
        at: 'temperature' put: 0.7;
        yourself).

client inference featureExtraction: 'sentence-transformers/all-MiniLM-L6-v2' input: 'hello'.

(client inference textToImage: 'stabilityai/sdxl-turbo' prompt: 'a red panda in a field')
    writeToFile: 'out.png'.
```

## Architecture

| Package                | Purpose                                                             |
|------------------------|---------------------------------------------------------------------|
| `HuggingFace-Core`     | Config, auth, `ZnClient` wrapper, typed error hierarchy, endpoints  |
| `HuggingFace-Hub`      | `HfApi`, repo info classes, file download/upload, commits, cache    |
| `HuggingFace-Inference`| Chat / text generation / embeddings / image generation              |
| `HuggingFace-Tests`    | Offline SUnit tests (URL building, JSON parsing, cache layout, ...) |

Errors all inherit from `HfError`:

- `HfAuthenticationError` (HTTP 401)
- `HfAuthorizationError`  (HTTP 403, non-gated)
- `HfGatedRepoError`      (HTTP 403, license not accepted)
- `HfRepositoryNotFoundError` (HTTP 404)
- `HfRateLimitError`      (HTTP 429 — automatically retried with backoff)
- `HfHttpError`           (any other non-2xx)
- `HfValidationError`     (client-side input validation)

The `HfHttpClient` retries 5xx / 429 / connection failures with exponential
backoff (capped at 30 s, up to `HfConfiguration >> maxRetries`).

## Cache layout

Identical to `huggingface_hub` in Python, so a folder populated by one
client is consumable by the other:

```
<cache>/
  models--<ns>--<name>/
    blobs/<sha>
    refs/<revision>
    snapshots/<sha>/<filename>   (symlink -> ../../blobs/<sha>)
```

Symlinks fall back to file copies on filesystems that do not support them.

## Running tests

```smalltalk
(TestSuite named: 'HuggingFace-Tests')
    addTests: (Smalltalk image allClasses
        select: [ :c | c package name = #'HuggingFace-Tests' ]
        thenCollect: [ :c | c buildSuite ]);
    run.
```

Or use the Test Runner UI and select the `HuggingFace-Tests` package. The
default suite runs offline; methods touching the network only execute when
a real token is configured.

## License

MIT — see `LICENSE`.
