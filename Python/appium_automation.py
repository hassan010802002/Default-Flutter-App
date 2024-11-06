from appium import webdriver
from appium.webdriver.webdriver import AppiumOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
# from appium.webdriver import MobileBy
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities

# Add any other capabilities you need



def automate_webview_button_click():
    options = AppiumOptions()
    # Set up Appium server connection
    options.set_capability("platformName", "Android")  
    options.set_capability("deviceName", "Hassan_Pro")
    options.set_capability("app", "C:\\Users\\Hassan\\Desktop\\DefaultApp\\Default_Flutter_App\\build\\app\\outputs\\flutter-apk\\app-debug.apk")
    options.set_capability("automationName", "Flutter")
    options.set_capability("noReset", True)
    options.set_capability("fullReset", False)
    

    # Connect to the Appium server
    driver = webdriver.Remote("http://192.168.1.2:8000/wd/hub",options= options)

    try:
        # Wait for the WebView widget in the Flutter app
        flutter_webview = WebDriverWait(driver, 20).until(
            EC.presence_of_element_located((By.CLASS_NAME, 'WebViewWidget'))
        )

        # Switch context to the WebView to interact with web elements
        contexts = driver.contexts
        driver.switch_to.context("WEBVIEW") if "WEBVIEW" in contexts else None

        # Locate the button by its HTML ID within the WebView and click it
        button = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.ID, "get-started__header"))
        )
        button.click()

    finally:
        # Quit the driver
        driver.quit()

