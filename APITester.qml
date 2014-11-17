import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

ApplicationWindow {
    title: qsTr("API Tester")
    width: Screen.desktopAvailableWidth * 0.7
    height: Screen.desktopAvailableHeight * 0.7

    GroupBox {
        id: inputGroupBox
        x: 7
        y: 0
        width: parent.width * 0.99
        height: parent.height * 0.4
        title: qsTr("Input")

        RowLayout {
            id: rowLayout1
            ExclusiveGroup { id: tabPositionGroup }
            width: parent.width
            RadioButton {
                id: getRadioButton
                text: "GET"
                checked: true
                exclusiveGroup: tabPositionGroup
            }
            RadioButton {
                id: postRadioButton
                text: qsTr("POST")
                anchors.left: getRadioButton.right
                anchors.leftMargin: 10
                exclusiveGroup: tabPositionGroup
            }

            TextField {
                id: urlTextField
                anchors.right: sendButton.left
                anchors.rightMargin: 10
                anchors.left: postRadioButton.right
                anchors.leftMargin: 10
                inputMask: ""
                placeholderText: qsTr("URL")
            }

            Button {
                id: sendButton
                text: qsTr("Send")
                anchors.right: parent.right
                anchors.rightMargin: 0

                onClicked: {
                    var method = getRadioButton.checked ? 'GET' : 'POST';
                    var url = urlTextField.text;
                    var content = inputTextArea.text;


                    responseTextArea.text = '';

                    if(url.length===0)
                    {
                        messageDialog.visible = true;
                    }
                    else
                    {
                        request(method, url, content, function (o) {
                            var status = 0
                            try {
                                status = o.status;
                            } catch(err) {
                                status = -1
                            }

                            if(o.readyState === XMLHttpRequest.DONE) {
                                if(o.responseText.length!==0) {
                                    try {
                                        responseTextArea.text = JSON.stringify(JSON.parse( o.responseText ), null, '    ');
                                    } catch(err) {
                                        responseTextArea.text = o.responseText;
                                    }
                                }
                            }
                            else {
                                responseTextArea.text = status + ' (empty)'
                            }
                        });
                    }
                }
            }
        }

        TextArea {
            id: inputTextArea
            text:
'content={
    "Login": {
        "account": "example-account",
        "password":"example-password"
    }
}'
            textColor: "#0d51ff"
            antialiasing: true
            font.family: "Courier"
            tabChangesFocus: false
            highlightOnFocus: false
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.top: rowLayout1.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            font.pointSize: 12
        }

        MessageDialog {
            id: messageDialog
            icon: StandardIcon.Information
            standardButtons: StandardButton.Ok
            title: "Input error"
            text: "The URL is invalid."
            Component.onCompleted: visible = false
        }
    }

    GroupBox {
        id: responseGroupBox
        x: 7
        y: inputGroupBox.y + inputGroupBox.height
        width: parent.width * 0.99
        height: (parent.height - inputGroupBox.y - inputGroupBox.height) * 0.99
        title: qsTr("Response")

        TextArea {
            id: responseTextArea
            textColor: "#0d51ff"
            font.pointSize: 12
            font.family: "Courier"
            highlightOnFocus: false
            antialiasing: true
            anchors.fill: parent
            readOnly: true
        }
    }

    // this function is included locally, but you can also include separately via a header definition
    function request(method, url, content, callback) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = (function(myxhr) {
            return function() { callback(myxhr) }
        })(xhr);

        xhr.open(method, url, true);
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        xhr.setRequestHeader("Content-length", content.length);
        xhr.setRequestHeader("Connection", "close");
        xhr.send(content);
    }
}
