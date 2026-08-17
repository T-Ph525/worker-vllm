# Worker image = official vLLM OpenAI server image + RunPod serverless wrapper.
# vLLM upgrades are now a single build ARG:
#   docker buildx build --build-arg VLLM_VERSION=v0.27.1 ...
ARG VLLM_VERSION=v0.27.1
FROM vllm/vllm-openai:${VLLM_VERSION}

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1

# RunPod serverless SDK + HTTP proxy deps (vLLM itself comes from the base image).
COPY builder/requirements.txt /requirements.txt
RUN python3 -m ensurepip --upgrade 2>/dev/null || true \
    && python3 -m pip install --no-cache-dir -r /requirements.txt

# Setup build arguments
ARG MODEL_NAME=""
ARG MODEL_REVISION=""
ARG TOKENIZER_NAME=""
ARG TOKENIZER_REVISION=""
ARG QUANTIZATION=""
ARG BASE_PATH="/runpod-volume"

# Ensure runtime directory exists even when network volume is not attached
RUN mkdir -p ${BASE_PATH}

# Set environment variables
ENV MODEL_NAME=$MODEL_NAME \
    MODEL_REVISION=$MODEL_REVISION \
    TOKENIZER_NAME=$TOKENIZER_NAME \
    TOKENIZER_REVISION=$TOKENIZER_REVISION \
    QUANTIZATION=$QUANTIZATION \
    BASE_PATH=$BASE_PATH \
    # Fixed HF_HOME path (do NOT append /hub to HF_HOME)
    HF_HOME="${BASE_PATH}/huggingface-cache" \
    HF_DATASETS_CACHE="${BASE_PATH}/huggingface-cache/datasets" \
    HF_HUB_ENABLE_HF_TRANSFER=0 \
    TOKENIZERS_PARALLELISM=false

# Copy application source code
COPY src /src

# Optionally bake the model into the image at build time.
# Pass HF_TOKEN build secret if the repo is gated:
#   docker buildx build --secret id=HF_TOKEN ... --build-arg MODEL_NAME=...
RUN --mount=type=secret,id=HF_TOKEN,required=false \
    if [ -n "$MODEL_NAME" ]; then \
        if [ -f /run/secrets/HF_TOKEN ]; then \
            export HF_TOKEN=$(cat /run/secrets/HF_TOKEN); \
        fi && \
        # If baking model into image, temporarily override HF_HOME to avoid mount shadows
        HF_HOME=/root/.cache/huggingface python3 /src/download_model.py; \
    fi

# Main runner script spawns `vllm serve` and manages health checks.
ENTRYPOINT ["python3", "/src/main.py"]
