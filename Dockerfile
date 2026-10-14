# Official vLLM image + RunPod serverless wrapper.
ARG VLLM_VERSION=v0.31.0
FROM vllm/vllm-openai:${VLLM_VERSION}

ARG VLLM_VERSION

# Install RunPod SDK and HTTP proxy dependencies.
COPY builder/requirements.txt /requirements.txt
RUN (python3 -m ensurepip --upgrade 2>/dev/null || true) \
    && python3 -m pip install --no-cache-dir -r /requirements.txt

# Preserve the base image's vLLM version when installing the plugin.
# bitsandbytes must be supplied by builder/requirements.txt.
RUN python3 -m pip install --no-cache-dir --no-deps \
    "vllm-bnb-plugin>=0.0.3"

# Fail if dependency installation changed the vLLM version.
RUN test "$(python3 -c 'import vllm; print(vllm.__version__)')" \
    = "${VLLM_VERSION#v}"

# Defaults can be overridden through runtime environment variables.
ARG MODEL_NAME="mrcuddle/CaptainEris-DavidAU-Fusion-12B"
ARG MODEL_REVISION=""
ARG TOKENIZER_NAME=""
ARG TOKENIZER_REVISION=""
ARG QUANTIZATION=""
ARG BASE_PATH="/runpod-volume"

ENV MODEL_NAME="${MODEL_NAME}" \
    MODEL_REVISION="${MODEL_REVISION}" \
    TOKENIZER_NAME="${TOKENIZER_NAME}" \
    TOKENIZER_REVISION="${TOKENIZER_REVISION}" \
    QUANTIZATION="${QUANTIZATION}" \
    BASE_PATH="${BASE_PATH}" \
    HF_HOME="${BASE_PATH}/huggingface-cache" \
    HF_HUB_CACHE="${BASE_PATH}/huggingface-cache/hub" \
    HUGGINGFACE_HUB_CACHE="${BASE_PATH}/huggingface-cache/hub" \
    HF_DATASETS_CACHE="${BASE_PATH}/huggingface-cache/datasets" \
    VLLM_CACHE_ROOT="${BASE_PATH}/vllm-cache" \
    HF_HUB_ENABLE_HF_TRANSFER=0 \
    TOKENIZERS_PARALLELISM=false \
    PYTHONUNBUFFERED=1

COPY src /src

# Model weights are downloaded at runtime, not during the image build.
ENTRYPOINT ["python3", "/src/main.py"]
