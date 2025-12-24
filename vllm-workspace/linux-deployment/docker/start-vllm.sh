#!/bin/bash
set -e

echo "============================================"
echo "🚀 Starting vLLM Server (INT4 AWQ Quantized)"
echo "============================================"

# 显示配置
echo "📦 Model: ${VLLM_MODEL:-casperhansen/llama-3.1-70b-instruct-awq}"
echo "🎮 GPU Memory Utilization: ${VLLM_GPU_MEMORY_UTILIZATION:-0.90}"
echo "💾 Max Model Length: ${VLLM_MAX_MODEL_LEN:-8192}"
echo "🔧 Tensor Parallel Size: ${VLLM_TENSOR_PARALLEL:-1}"
echo "📊 Quantization: ${VLLM_QUANTIZATION:-awq}"
echo "============================================"

# 检查 GPU 可用性
if ! nvidia-smi &> /dev/null; then
    echo "❌ Error: No NVIDIA GPU detected!"
    echo "Please ensure:"
    echo "  1. NVIDIA drivers are installed"
    echo "  2. Docker is configured with GPU support (nvidia-docker2)"
    echo "  3. docker-compose.yml has GPU reservations configured"
    exit 1
fi

echo ""
echo "✅ GPU Information:"
nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader
echo ""

# 检查 Hugging Face Token（用于下载模型）
if [ -z "$HUGGING_FACE_HUB_TOKEN" ]; then
    echo "⚠️  Warning: HUGGING_FACE_HUB_TOKEN not set"
    echo "   Some models may not be accessible"
    echo ""
fi

# 设置默认值
VLLM_MODEL="${VLLM_MODEL:-casperhansen/llama-3.1-70b-instruct-awq}"
VLLM_PORT="${VLLM_PORT:-8000}"
VLLM_HOST="${VLLM_HOST:-0.0.0.0}"
VLLM_MAX_MODEL_LEN="${VLLM_MAX_MODEL_LEN:-8192}"
VLLM_GPU_MEMORY_UTILIZATION="${VLLM_GPU_MEMORY_UTILIZATION:-0.90}"
VLLM_TENSOR_PARALLEL="${VLLM_TENSOR_PARALLEL:-1}"
VLLM_QUANTIZATION="${VLLM_QUANTIZATION:-awq}"

# 构建启动命令
CMD="python3 -m vllm.entrypoints.openai.api_server"
CMD="$CMD --model $VLLM_MODEL"
CMD="$CMD --port $VLLM_PORT"
CMD="$CMD --host $VLLM_HOST"
CMD="$CMD --max-model-len $VLLM_MAX_MODEL_LEN"
CMD="$CMD --gpu-memory-utilization $VLLM_GPU_MEMORY_UTILIZATION"
CMD="$CMD --tensor-parallel-size $VLLM_TENSOR_PARALLEL"
CMD="$CMD --quantization $VLLM_QUANTIZATION"
CMD="$CMD --download-dir /models"

# 添加可选的 API Key
if [ -n "$VLLM_SERVER_API_KEY" ]; then
    CMD="$CMD --api-key $VLLM_SERVER_API_KEY"
    echo "🔐 API Key authentication enabled"
fi

# 启用 HF Transfer 加速下载
export HF_HUB_ENABLE_HF_TRANSFER=1

echo ""
echo "🔨 Launch command:"
echo "$CMD"
echo ""
echo "⏳ Starting vLLM server (this may take several minutes for first-time model download)..."
echo ""

# 执行启动命令
exec $CMD
