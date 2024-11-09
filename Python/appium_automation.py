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
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities

# Add any other capabilities you need



def automate_webview_button_click():
    options = AppiumOptions()
    # Set up Appium server connection
    options.set_capability("platformName", "Android")  
    options.set_capability("appium:deviceName", "Hassan_Pro")
    options.set_capability("appium:app", "C:\\Users\\Hassan\\Desktop\\DefaultApp\\Default_Flutter_App\\build\\app\\outputs\\flutter-apk\\app-debug.apk")
    options.set_capability("appium:automationName", "UiAutomator2")
    options.set_capability("appium:noReset", True)
    options.set_capability("appium:fullReset", False)
    options.set_capability("appium:chromedriverExecutable", "C:\\Users\\Hassan\\Downloads\\chromedriver-win64\\chromedriver.exe")
    options.set_capability("appium:ensureWebviewsHavePages", True)
    options.set_capability("appium:newCommandTimeout", 3600)
    options.set_capability("appium:uiautomator2ServerLaunchTimeout", 30000)
    

    # Connect to the Appium server
    driver = webdriver.Remote("http://192.168.1.2:8000",options= options)

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
        element = driver.find_element(AppiumBy.XPATH,"//*[@id='loginsubmit_loginId']")
        print("Element Found")
        actions = ActionChains(driver)
        actions.move_to_element(element).click().perform()
        driver.implicitly_wait(2)
        element.send_keys("hassan123")
        print("Element Event Attached")
        
        # UserID Input Field
        element = driver.find_element(AppiumBy.XPATH,"//*[@id='loginsubmit_userId']")
        print("Element Found")
        actions = ActionChains(driver)
        actions.move_to_element(element).click().perform()
        driver.implicitly_wait(2)
        element.send_keys("hassan123")
        print("Element Event Attached")
        
        # Password Input Field
        element = driver.find_element(AppiumBy.XPATH,"//*[@id='password']")
        print("Element Found")
        actions = ActionChains(driver)
        actions.move_to_element(element).click().perform()
        driver.implicitly_wait(2)
        element.send_keys("123456789")
        print("Element Event Attached")
        
        # Captcha Input Field
        element = driver.find_element(AppiumBy.XPATH,"//*[@id='loginsubmit_captchaid']")
        print("Element Found")
        actions = ActionChains(driver)
        actions.move_to_element(element).click().perform()
        driver.implicitly_wait(2)
        element.send_keys("123456")
        print("Element Event Attached")
        
        driver.implicitly_wait(2)
        
        image_element = driver.find_element(AppiumBy.XPATH, "//*[@id='captchaimg']")
        print("Element Found")
        image_url = image_element.get_attribute("src")
        driver.implicitly_wait(5)
        response = requests.get(image_url)
        driver.implicitly_wait(5)
        image = Image.open(BytesIO(response.content))
        driver.implicitly_wait(5)
        captcha_text = pytesseract.image_to_string(image)
        print("Element Event Attached")
        print("Extracted CAPTCHA Text:", captcha_text)

        
        # # LogIn Button
        # element = driver.find_element(AppiumBy.XPATH,"//*[@id='btnSubmit']")
        # print("Element Found")
        # element.click()
        # # actions = ActionChains(driver)
        # # actions.move_to_element(element).click().perform()
        # # driver.implicitly_wait(2)
        # # element.send_keys("123456")
        # print("Element Event Attached")
        
        # Switch back to native context if needed
        driver.switch_to.context("NATIVE_APP")
        print("Switched Back to:",driver.context)
        

    finally:
        # Quit the driver
        driver.quit()

