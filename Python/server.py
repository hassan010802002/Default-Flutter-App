from flask import Flask, jsonify
from appium_automation import automate_webview_button_click

app = Flask(__name__)

@app.route('/click-button', methods=['POST'])
def click_button():
    try:
        automate_webview_button_click()
        return jsonify({"status": "success", "message": "Button clicked successfully!"})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=6000)
