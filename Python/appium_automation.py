from appium import webdriver
from appium.webdriver.webdriver import AppiumOptions
from selenium.webdriver.common.by import By
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.action_chains import ActionChains

# Add any other capabilities you need



def automate_webview_button_click(server_url, app_path, chromedriver_path, device_name, login_id, user_id, password , captcha_text):
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
        
        if len(captcha_text) < 6:
            refreshView(appiumDriver=driver,captcha_text=captcha_text)
            return

        fields = {
            "//*[@id='loginsubmit_loginId']": login_id,
            "//*[@id='loginsubmit_userId']": user_id,
            "//*[@id='password']": password,
            "//*[@id='loginsubmit_captchaid']": captcha_text,
        }
        
        for xpath, input_text in fields.items():
            insertData(appiumDriver=driver,input_text=input_text,xpath=xpath)
        
        clickLoginButton(appiumDriver=driver)

        driver.implicitly_wait(5)
        
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
    appiumDriver.implicitly_wait(5)
    
def refreshView(appiumDriver,captcha_text):
    # Execute JavaScript to reload the page
    print("The Captcha Text is: ",captcha_text)
    appiumDriver.execute_script("window.location.reload();")
    print("Refreshing WebView")


def insertData(appiumDriver , xpath, input_text):
    try:
        element = appiumDriver.find_element(AppiumBy.XPATH, xpath)
        actions = ActionChains(appiumDriver)
        actions.move_to_element(element).click().perform()
        appiumDriver.implicitly_wait(3)
        element.send_keys(input_text)
        print(f"Filled field with XPath: {xpath} --- Value {input_text} successfully.")
        print("Element Event Attached")
    except Exception as e:
        print(f"Error in filling field {xpath}: {e}")

def verifyCaptchaData(appiumDriver,captchaText):
    print("Captcha Text is: ",captchaText)
    print("Captcha Text Length is:",len(captchaText))
    appiumDriver.implicitly_wait(5)
    clickLoginButton(appiumDriver=appiumDriver)