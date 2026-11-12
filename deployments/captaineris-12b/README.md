# CaptainEris 12B RunPod Serverless
Model: `mrcuddle/CaptainEris-DavidAU-Fusion-12B`.

The Dockerfile downloads model weights during image build. The worker runs offline with `MODEL_NAME=/models/CaptainEris-DavidAU-Fusion-12B`.

GitHub Actions publishes `ghcr.io/t-ph525/captaineris-vllm:latest`. Make the GHCR package public (or configure RunPod registry credentials) before deployment. Recommended RunPod QUEUE endpoint: 1 x 48/80GB GPU, min workers 0, max 2, 60+GB disk, queue-delay scaling. This configuration has not yet been runtime tested.
