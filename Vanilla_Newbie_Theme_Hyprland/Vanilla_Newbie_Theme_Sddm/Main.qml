import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    anchors.fill: parent

    // --- TAVOLOZZA COLORI ---
    readonly property color colCyan: "#00FFFF"
    readonly property color colMagenta: "#FF00FF"
    readonly property color colDarkBg: "#D9000000" // Nero assoluto (000000) al 85% di opacità
    readonly property color colInputBg: "#F2000000" // Nero quasi totale per i campi
    readonly property color colDeepDark: "#000000"
    readonly property color colError: "#FF3333"

    // SFONDO
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "vanilla_wallpaper.png"
        fillMode: Image.PreserveAspectCrop
        
        Rectangle {
            anchors.fill: parent
            color: "black"
            visible: backgroundImage.status !== Image.Ready
        }
    }

    // GESTIONE ERRORI
    Connections {
        target: sddm
        function onLoginFailed() {
            passwordField.text = ""
            errorMessage.visible = true
            passwordField.focus = true
        }
    }

    // --- OROLOGIO E DATA (In alto a destra) ---
    Column {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 60
        spacing: 0
        
        Text {
            id: clockLabel
            text: Qt.formatDateTime(new Date(), "hh:mm")
            font.pixelSize: 130
            font.bold: true
            color: colMagenta
            horizontalAlignment: Text.AlignRight
        }
        Text {
            text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
            font.pixelSize: 32
            color: colCyan // Colore Cyan come richiesto
            font.bold: true
            anchors.right: parent.right
        }
    }

    // --- BOX DI LOGIN (Con bordo Cyan) ---
    Rectangle {
        id: loginBox
        anchors.centerIn: parent
        width: 550
        height: 720
        color: colDarkBg // Nero traslucido
        radius: 20
        border.width: 3  // Bordo più visibile
        border.color: colCyan // Bordo Cyan per il quadrato centrale

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 60
            spacing: 15

            Text {
                text: "SYSTEM ACCESS"
                font.pixelSize: 32
                font.bold: true
                font.letterSpacing: 4
                color: colCyan
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 30
            }

            // --- USERNAME ---
            Text {
                text: "USERNAME"
                font.pixelSize: 18
                font.bold: true
                color: colCyan
            }
            TextField {
                id: usernameField
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                placeholderText: "Identify yourself..."
                text: userModel.lastUser
                color: "white"
                font.pixelSize: 18
                leftPadding: 20
                background: Rectangle {
                    color: colInputBg // Nero assoluto traslucido
                    border.color: colCyan // Sempre colorato
                    border.width: usernameField.activeFocus ? 3 : 1.5
                    radius: 10
                }
            }

            // --- PASSWORD ---
            Item { Layout.preferredHeight: 15 }
            Text {
                text: "PASSWORD"
                font.pixelSize: 18
                font.bold: true
                color: colMagenta
            }
            TextField {
                id: passwordField
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                placeholderText: "Security key..."
                echoMode: TextInput.Password
                color: "white"
                font.pixelSize: 18
                leftPadding: 20
                focus: true
                background: Rectangle {
                    color: colInputBg // Nero assoluto traslucido
                    border.color: colMagenta // Sempre colorato
                    border.width: passwordField.activeFocus ? 3 : 1.5
                    radius: 10
                }
                onAccepted: loginButton.clicked()
            }

            // --- SESSION ---
            Item { Layout.preferredHeight: 15 }
            Text {
                text: "ENVIRONMENT"
                font.pixelSize: 18
                font.bold: true
                color: "white"
                opacity: 0.8
            }
            ComboBox {
                id: sessionSelector
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                model: sessionModel
                currentIndex: sessionModel.lastIndex
                textRole: "name"
                
                contentItem: Text {
                    text: sessionSelector.displayText
                    color: colCyan
                    font.pixelSize: 18
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 20
                }
                
                background: Rectangle {
                    color: colInputBg
                    border.color: "white"
                    border.width: 1
                    radius: 10
                    opacity: 0.5
                }

                delegate: ItemDelegate {
                    width: sessionSelector.width
                    contentItem: Text {
                        text: model.name
                        color: hovered ? "black" : colCyan
                        font.bold: true
                        font.pixelSize: 16
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 20
                    }
                    background: Rectangle {
                        color: hovered ? colCyan : colDeepDark
                    }
                }
            }

            Text {
                id: errorMessage
                text: "✕ ACCESS DENIED"
                color: colError
                font.pixelSize: 16
                font.bold: true
                visible: false
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 10
            }

            // --- LOGIN BUTTON ---
            Button {
                id: loginButton
                Layout.fillWidth: true
                Layout.preferredHeight: 65
                Layout.topMargin: 25
                
                contentItem: Text {
                    text: "INITIALIZE LOGIN"
                    color: loginButton.hovered ? "white" : "black"
                    font.bold: true
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: loginButton.hovered ? colMagenta : colCyan // Magenta al passaggio del mouse
                    radius: 10
                    border.width: loginButton.activeFocus ? 3 : 0
                    border.color: "white"
                }

                onClicked: {
                    errorMessage.visible = false
                    sddm.login(usernameField.text, passwordField.text, sessionSelector.currentIndex)
                }
            }
        }
    }

    // --- POWER BUTTONS ---
    RowLayout {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 50
        spacing: 20

        Button {
            id: rebootBtn
            implicitWidth: 160
            implicitHeight: 50
            onClicked: sddm.reboot()
            contentItem: Text { 
                text: "REBOOT"
                color: rebootBtn.hovered ? "black" : colCyan
                font.bold: true
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: rebootBtn.hovered ? colCyan : "transparent"
                border.color: colCyan
                border.width: 2
                radius: 8
            }
        }

        Button {
            id: shutdownBtn
            implicitWidth: 160
            implicitHeight: 50
            onClicked: sddm.powerOff()
            contentItem: Text { 
                text: "SHUTDOWN"
                color: shutdownBtn.hovered ? "black" : colError
                font.bold: true
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: shutdownBtn.hovered ? colError : "transparent"
                border.color: colError
                border.width: 2
                radius: 8
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clockLabel.text = Qt.formatDateTime(new Date(), "hh:mm")
    }
}
