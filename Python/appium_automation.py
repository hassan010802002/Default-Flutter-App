from appium import webdriver
from appium.webdriver.webdriver import AppiumOptions
from selenium.webdriver.common.by import By
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.action_chains import ActionChains
from PIL import Image
import pytesseract
from io import BytesIO
import requests
import base64
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities

# Add any other capabilities you need



def automate_webview_button_click(server_url, app_path, chromedriver_path, device_name, login_id, user_id, password):
    options = AppiumOptions()
    # Set up Appium server connection
    options.set_capability("platformName", "Android")  
    options.set_capability("appium:deviceName", device_name)
    options.set_capability("appium:app", app_path)
    options.set_capability("appium:automationName", "UiAutomator2")
    options.set_capability("appium:noReset", True)
    options.set_capability("appium:fullReset", False)
    options.set_capability("appium:chromedriverExecutable", chromedriver_path)
    options.set_capability("appium:ensureWebviewsHavePages", True)
    options.set_capability("appium:newCommandTimeout", 3600)
    options.set_capability("appium:uiautomator2ServerLaunchTimeout", 30000)
    

    # Connect to the Appium server
    driver = webdriver.Remote(server_url,options= options)

    try:
        # Wait for the WebView widget in the Flutter app
        WebDriverWait(driver, 20).until(
            EC.presence_of_element_located((AppiumBy.CLASS_NAME, 'android.webkit.WebView'))
        )
        contexts = driver.contexts
        print("Available contexts:", contexts)
        
        webview_context = [context for context in contexts if 'WEBVIEW_com.example.appium_test' in context]
        driver.switch_to.context(webview_context[0])
        print("Switched to Context:", webview_context[0])
            
            # LoginID Input Field
        fields = {
            "//*[@id='loginsubmit_loginId']": login_id,
            "//*[@id='loginsubmit_userId']": user_id,
            "//*[@id='password']": password,
        }

        for xpath, input_text in fields.items():
            try:
                element = driver.find_element(AppiumBy.XPATH, xpath)
                actions = ActionChains(driver)
                actions.move_to_element(element).click().perform()
                driver.implicitly_wait(3)
                element.send_keys(input_text)
                print(f"Filled field with XPath: {xpath} --- Value {input_text} successfully.")
                print(f"Element Event Attached")
            except Exception as e:
                print(f"Error in filling field {xpath}: {e}")
        
        captcha_text = extractCaptchaText(appiumDriver=driver)

        length = len(captcha_text)

        verifyCaptchaData(appiumDriver=driver,length=length)

        driver.implicitly_wait(2)
        
        # Switch back to native context if needed
        driver.switch_to.context("NATIVE_APP")
        print("Switched Back to:",driver.context)
        

    finally:
        # Quit the driver
        driver.quit()

# ------------------------------------------------------------------------------------------------------------- #

def clickLoginButton(appiumDriver):
    # LogIn Button
    element = appiumDriver.find_element(AppiumBy.XPATH,"//*[@id='btnSubmit']")
    print("Element Found")
    element.click()
    print("Element Event Attached")


def clickRefreshButton(appiumDriver):
    # Refresh Button
    element = appiumDriver.find_element(AppiumBy.XPATH,"/html/body/form/div[2]/div[2]/div[1]/div/div[6]/i")
    print("Element Found")
    element.click()


def insertCaptchaText(appiumDriver , captchaText):
    # Captcha Input Field
    element = appiumDriver.find_element(AppiumBy.XPATH,"//*[@id='loginsubmit_captchaid']")
    print("Element Found")
    actions = ActionChains(appiumDriver)
    actions.move_to_element(element).click().perform()
    appiumDriver.implicitly_wait(3)
    element.send_keys(captchaText)
    print("Element Event Attached")


def extractCaptchaText(appiumDriver):
    pytesseract.pytesseract.tesseract_cmd = r'C:\Users\Hassan.Saeed\AppData\Local\Programs\Tesseract-OCR\tesseract.exe'
    image_element = appiumDriver.find_element(AppiumBy.XPATH, "//*[@id='captchaimg']")
    print("Captcha Image Element Found")
    image_src = image_element.get_attribute("src")
    print("Captcha Image src data: ",image_src)
    appiumDriver.implicitly_wait(3)
    if image_src.startswith("data:image/png;base64"):
        # Remove the prefix to get the pure base64 string
        base64_str = image_src.split(",")[1]
    image_data = base64.b64decode(base64_str)
    print("Captcha Image base64 data: ",base64_str)
    appiumDriver.implicitly_wait(3)
    image = Image.open(BytesIO(image_data))
    print("Captcha Image Opened")
    appiumDriver.implicitly_wait(3)
    image.save('captcha.png')
    print("Captcha Image Saved with Name: captcha.png")
    appiumDriver.implicitly_wait(3)
    captcha_text = pytesseract.image_to_string("captcha.png")
    print("Extracted CAPTCHA Text:", captcha_text)
    print("Element Event Attached")
    return captcha_text


def verifyCaptchaData(appiumDriver,length):
    print("Captcha Text Length is: ",length)
    appiumDriver.implicitly_wait(5)
    if length == 6:
        print("Valid Captcha Text")
        insertCaptchaText(appiumDriver=appiumDriver,captchaText=captcha_text)
        appiumDriver.implicitly_wait(5)
        clickLoginButton(appiumDriver=appiumDriver)
        return
    else:
        print("Extracted Captcha Text is Not Valid ---- Please Try Again")
        clickRefreshButton(appiumDriver=appiumDriver)
        print("Refreshing Captcha Text with Refresh Button")
        print("Extracting Captcha Text Again")
        appiumDriver.implicitly_wait(5)
        captcha_text = extractCaptchaText(appiumDriver=appiumDriver)
        length = len(captcha_text)
        verifyCaptchaData(appiumDriver= appiumDriver , length=length)