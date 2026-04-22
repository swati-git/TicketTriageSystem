
from azure.ai.inference import ChatCompletionsClient
from azure.ai.inference.models import ChatCompletions, SystemMessage, UserMessage
from azure.identity import DefaultAzureCredential, get_bearer_token_provider
import os
import logging
import sys

# ---- Logging setup ----
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)]  # explicitly to stdout
)
logger = logging.getLogger(__name__)

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

# ---- Config ----
COGNITIVE_ACCOUNT_ENDPOINT = os.environ.get("AZURE_OPENAI_ENDPOINT")
COGNITIVE_DEPLOYMENT_NAME = os.environ.get("AZURE_OPENAI_DEPLOYMENT")

if not COGNITIVE_ACCOUNT_ENDPOINT:
    logger.error("COGNITIVE_ACCOUNT_ENDPOINT is not set")
    sys.exit(1)

if not COGNITIVE_DEPLOYMENT_NAME:
    logger.error("COGNITIVE_DEPLOYMENT_NAME is not set")
    sys.exit(1)

# ---- Client ----
logger.info("Initialising credential...")
credential = DefaultAzureCredential()

deployment_endpoint = f"{COGNITIVE_ACCOUNT_ENDPOINT.rstrip('/')}/openai/deployments/{COGNITIVE_DEPLOYMENT_NAME}"


inference_client = ChatCompletionsClient(
    endpoint=deployment_endpoint,
    credential=credential,
    credential_scopes=["https://cognitiveservices.azure.com/.default"],
    api_version="2025-01-01-preview"
)
logger.info("ChatCompletionsClient initialised successfully")

print("--- Testing token acquisition for Foundry audience ---")
try:
    token = credential.get_token("https://ai.azure.com/.default")
    print(f"✅ Token acquired for https://ai.azure.com")
    print(f"   Expires: {token.expires_on}")
except Exception as e:
    print(f"❌ Failed to get token for https://ai.azure.com: {e}")

# Test 2 — try acquiring token for Cognitive Services audience
print("--- Testing token acquisition for Cognitive Services audience ---")
try:
    token = credential.get_token("https://cognitiveservices.azure.com/.default")
    print(f"✅ Token acquired for https://cognitiveservices.azure.com")
    print(f"   Expires: {token.expires_on}")
except Exception as e:
    print(f"❌ Failed to get token for https://cognitiveservices.azure.com: {e}")


logger.info("Sending request to deployment: %s", COGNITIVE_DEPLOYMENT_NAME)
response: ChatCompletions = inference_client.complete(
    model=COGNITIVE_DEPLOYMENT_NAME,
    messages=[
        SystemMessage(content="You are a helpful assistant."),
        UserMessage(content="Say hello in one word."),
    ],
    max_tokens=10,
)


# ---- Log the result ----
logger.info("Response received successfully")
logger.info("Content: %s", response.choices[0].message.content)
logger.info("Finish reason: %s", response.choices[0].finish_reason)
logger.info("Tokens used — prompt: %d, completion: %d, total: %d",
    response.usage.prompt_tokens,
    response.usage.completion_tokens,
    response.usage.total_tokens,
)