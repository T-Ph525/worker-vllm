FROM runpod/worker-v1-vllm:latest
ARG MODEL_REPO=mrcuddle/CaptainEris-DavidAU-Fusion-12B
ENV HF_HOME=/models/hf-cache \
    HF_HUB_OFFLINE=1 \
    MODEL_NAME=/models/CaptainEris-DavidAU-Fusion-12B
RUN python -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='mrcuddle/CaptainEris-DavidAU-Fusion-12B', local_dir='/models/CaptainEris-DavidAU-Fusion-12B')" 
