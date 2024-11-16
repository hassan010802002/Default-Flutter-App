from login_automation import login_webview_automation
from fastapi import FastAPI, HTTPException,BackgroundTasks
from pydantic import BaseModel
import logging
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Enable CORS for all origins (adjust as needed)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins. Replace with specific domains for security.
    allow_methods=["*"],  # Allow all HTTP methods.
    allow_headers=["*"],  # Allow all headers.
)

# Set up logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

# Request model validation
class AutomationRequest(BaseModel):
    serverUrl: str
    loginId: str
    userId: str
    password: str
    app: str
    deviceName: str
    driverPath: str
    captchaText: str

def run_automation(request_data: AutomationRequest):
    # Run the automation task
    login_webview_automation(
        server_url=request_data.serverUrl,
        app_path=request_data.app,
        chromedriver_path=request_data.driverPath,
        device_name=request_data.deviceName,
        login_id=request_data.loginId,
        user_id=request_data.userId,
        password=request_data.password,
        captcha_text=request_data.captchaText,
    )

@app.post("/click-button")
async def click_button(request: AutomationRequest , background_tasks: BackgroundTasks):
    """
    Endpoint to handle automation requests for Appium.
    """
    logger.info("Received automation request.")
    try:
        # Add the automation task to run in the background
        background_tasks.add_task(
            run_automation,
            request,
        )
        logger.info("Button clicked successfully.")
        return {"status": "success", "message": "Button clicked successfully!"}
    except Exception as e:
        print(f"Error: {e}")
        raise HTTPException(status_code=400, detail=str(e))

# Run the app in ASGI mode (use uvicorn for production)
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=6000)
