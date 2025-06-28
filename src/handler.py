import runpod
import logging
import asyncio
from utils import JobInput
from engine import vLLMEngine, OpenAIvLLMEngine

# Set up basic logging
logging.basicConfig(level=logging.INFO)

# Initialize engines outside the handler function
logging.info("Initializing engines...")
vllm_engine = vLLMEngine()
openai_vllm_engine = OpenAIvLLMEngine(vllm_engine)
logging.info("Engines initialized.")

async def async_handler(job):
    try:
        logging.info(f"Starting job processing for job: {job}")

        # Access the input from the request
        job_input = JobInput(job["input"])

        # Determine which engine to use based on job input
        engine = openai_vllm_engine if job_input.openai_route else vllm_engine

        # Simulate or implement progress updates
        total_updates = 5
        for update_number in range(total_updates):
            logging.info(f"Progress update {update_number + 1}/{total_updates}")
            await asyncio.sleep(1)  # Simulate task processing

            # Send progress update
            runpod.serverless.progress_update(job, f"Progress: {update_number + 1}/{total_updates}")

        # Process job with selected engine (simplified for the example)
        results_generator = engine.generate(job_input)
        results = []
        async for batch in results_generator:
            results.extend(batch)

        # Return the results and indicate the worker should be refreshed
        return {
            "refresh_worker": True,
            "job_results": results
        }

    except Exception as e:
        logging.error(f"Error during job processing: {e}")
        return {
            "error": str(e)
        }

# Configure and start the Runpod serverless function
runpod.serverless.start(
    {
        "handler": async_handler,  # Specify the async handler
        "return_aggregate_stream": True,
    }
)
