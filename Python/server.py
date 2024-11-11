from flask import Flask, jsonify , request
from appium_automation import automate_webview_button_click

app = Flask(__name__)

@app.route('/click-button', methods=['POST'])
def click_button():
    try:
        # Access the JSON data from the request body
        if not request.is_json:
            return jsonify({"status": "error", "message": "Request must be JSON"}), 400
        data = request.get_json(force=True)
        
        # Extract specific data fields
        serverUrl = data.get("serverUrl")
        print("Server Url",serverUrl)
        loginId = data.get("loginId")
        userId = data.get("userId")
        password = data.get("password")
        app = data.get("app")
        deviceName = data.get("deviceName")
        driverPath = data.get("driverPath")

        automate_webview_button_click(server_url=serverUrl,app_path=app,chromedriver_path=driverPath,device_name=deviceName,login_id=loginId,user_id=userId,password=password)
        return jsonify({"status": "success", "message": "Button clicked successfully!"}) , 200
    except Exception as e:
        return jsonify({"status": "error", "message": e.__str__()}), 400

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=6000)
