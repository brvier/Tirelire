import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import "components"

Page {
    tools: settingsTools
    id: settingsPage

        PageHeader {
            id: pageHeader
            title:'Tirelire : Settings'
            showSolde: false
        }

    TitleLabel {
        id: moneyUnitLabel
        text: 'Monney Symbol'
        anchors.top: pageHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
    }

    TextField {
        id: monneyUnitField
        placeholderText: '€'
        text: py.getSetting('currencysymbol')
        onTextChanged: {
            py.setSetting('currencysymbol', monneyUnitField.text)
        }
        anchors.top: moneyUnitLabel.bottom
        anchors.margins: 10
        anchors.left: parent.left
        anchors.right: parent.right
    }


    ToolBarLayout {
        id: settingsTools
        visible: false
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: {
                pageStack.pop();
            }
        }

    }
}

