# 🚀 Quick Deploy to Modal.com

Push the tea-order agent to Modal within minutes.

## Step 1: Install Modal

```bash
pip install modal
```

## Step 2: Log in

```bash
modal token new
```

A browser window opens for authentication.

## Step 3: Create Secrets

Go to https://modal.com/secrets and create a secret named `tea-agent-secrets` with:

```
ASSEMBLYAI_API_KEY=your-assemblyai-key
OPENROUTER_API_KEY=your-openrouter-key
```

Optional extras for fine tuning:

```
OPENROUTER_MODEL=meta-llama/llama-3.3-70b-instruct
OPENROUTER_SITE_URL=https://your-site.example.com
OPENROUTER_SITE_NAME=Tea Order Agent
ASSEMBLYAI_TTS_VOICE=alloy
OPENAI_TEMPERATURE=0.7
```

## Step 4: Deploy the Backend

### Recommended
```bash
./deploy.sh
```

### Manual
```bash
modal deploy modal_app.py
```

## Step 5: Bonus - vLLM Backup

To add the Modal-hosted vLLM 70B fallback:

```bash
cd vllm-workspace
./scripts/deploy_vllm.sh
# or
modal deploy modal/modal_vllm.py
```

Copy the returned `https://.../v1` URL into `.env` as `VLLM_BASE_URL` and set `VLLM_API_KEY` if required.

## Step 6: Configure Frontend

Set the API URL in `frontend/.env`:

```env
VITE_API_URL=https://your-username--tea-order-agent-fastapi-app.modal.run
```

## Step 7: Validate

- Open `https://your-username--tea-order-agent-fastapi-app.modal.run` to view API welcome.
- Check `/health` and the frontend at http://localhost:3000 (when running locally).

## Extra Resources
- Detailed deployment guide: [MODAL_DEPLOYMENT.md](./MODAL_DEPLOYMENT.md)
- Linux vLLM alternative: `vllm-workspace/linux-deployment/README.md`
- Logs: `modal app logs tea-order-agent --follow`
- Update: `modal deploy modal_app.py` after every change.
