import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import "components"

Page {
    tools: editTools
    id: editPage
    property int uid: 0
    property string moneyUnit: py.getSetting('currencysymbol')
    property alias desc: descField.text
    property double date: 0
    property double amount: 0
    property bool positive: false

    onAmountChanged: {
        var damount = new Number(amount)/100;
        amountField.text = formatMoney(damount);
    }

    onDateChanged: {
        var ddate = new Date()
        console.log('onDateChanged')
        if (date != 0) {
            console.log('onDateChanged !=')
            ddate.setTime(date * 1000);
        }
        dateField.text = Qt.formatDate(ddate);
    }

    function save() {
        py.insertOrUpdate(uid, date, desc, positive ? amount : -amount);
    }

    function showDatePicker(){
        var d = new Date();
        if (date !== 0) {
            d.setTime(date * 1000);
        }
        datePickerDialog.year = d.getFullYear();
        datePickerDialog.month = d.getMonth() + 1;
        datePickerDialog.day = d.getDate();
        datePickerDialog.open();
    }

    function datePickerAccepted(){
        var ddate = new Date();
        ddate.setMonth(datePickerDialog.month - 1);
        ddate.setYear(datePickerDialog.year);
        ddate.setDate(datePickerDialog.day);
        date = Math.round((ddate.getTime() / 1000));
        dateField.text = Qt.formatDate(ddate);
    }

    PageHeader {
        id: pageHeader
        title:'Tirelire'
    }

    Row {
        id: amountDateRow
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top: pageHeader.bottom
        anchors.topMargin: 10
        spacing: 10

        Button {
            id: sign
            text: positive ? '+' : '-'
            width: 50
            onClicked: {
                positive = !positive;
            }
        }

        TextField {
            id: amountField
            validator:  IntValidator{ top: 1000000 }
            width: parent.width - dateField.width - 60
            placeholderText: '0.00'
            text: Math.abs(amount)

            readOnly: true

            Label {
                id: moneyLabel
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                text: moneyUnit
            }
        }

        Button {
            id: dateField
            width: 160
            text: date
            onClicked: {
                showDatePicker()
            }
        }
    }

    ListModel {
        id: descModel

        function fill(data) {
            descModel.clear();
            for (var i=0; i<data.length; i++) {
                console.log(data[i]);
                descModel.append(data[i]);
            }
        }
    }
    Connections {
        target: pyCat
        onMessage: {
            descModel.fill(data);
        }
        Component.onCompleted: {
            pyCat.listCategories();
        }
    }

    TextField {
        id: descField
        anchors.top: amountDateRow.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        placeholderText: 'Title'
        text: desc

        Image {
            id: addText
            anchors.right: parent.right
            anchors.rightMargin: 15
            smooth: true
            fillMode: Image.PreserveAspectFit
            source: "image://theme/icon-m-toolbar-add"
            height: parent.height / 2; width: parent.height / 2
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                id: add
                anchors.fill: parent
                onClicked: textSelection.open()
            }

            SelectionDialog {
                id: textSelection
                titleText: "Description"
                selectedIndex: -1
                model: descModel

                onAccepted: {
                    descField.text = textSelection.model.get(textSelection.selectedIndex).name
                    descField.forceActiveFocus()
                }

                onRejected: selectedIndex = -1
            }
        }
    }

    Flow {
        anchors.top: descField.bottom
        anchors.topMargin: 10
        spacing: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20

        BigThreateningRedButton {
            text:'7'
        }
        BigThreateningRedButton {
            text:'8'
        }
        BigThreateningRedButton {
            text:'9'
        }
        BigThreateningRedButton {
            text:'4'
        }
        BigThreateningRedButton {
            text:'5'
        }
        BigThreateningRedButton {
            text:'6'
        }
        BigThreateningRedButton {
            text:'3'
        }
        BigThreateningRedButton {
            text:'2'
        }
        BigThreateningRedButton {
            text:'1'
        }
        BigThreateningRedButton {
            text:'00'
        }
        BigThreateningRedButton {
            text:'0'
        }
        BigThreateningRedButton {
            text:'C'
        }
    }

    DatePickerDialog{
        id:datePickerDialog
        titleText: "Select Date"
        parent: editPage
        onAccepted: {datePickerAccepted()}
    }

    ToolBarLayout {
        id: editTools
        visible: false
        ToolIcon {
            platformIconId: "toolbar-done"
            onClicked: {
                save();
                pageStack.pop();
            }
        }

        ToolIcon {
            platformIconId: "toolbar-undo"
            onClicked: {
                pageStack.pop();
            }
        }

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: (editMenu.status === DialogStatus.Closed) ? editMenu.open() : editMenu.close()
        }
    }

    Menu {
        id: editMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem {
                text: qsTr("About");
                onClicked: {
                    var aboutPage = Qt.createComponent(Qt.resolvedUrl('components/AboutPage.qml'))
                    pageStack.push(aboutPage, {title: 'Tirelire',
                                               slogan: 'Version '+version,
                                               iconSource: Qt.resolvedUrl('../../icons/Tirelire.svg'),
                                               text: description + '<br><br><b>Changeslog</b><br><br>'+changeslogs})
                }
            }
            MenuItem {
                text: qsTr("Delete");
                onClicked: {
                    deleteQueryDialog.uid = uid;
                    deleteQueryDialog.open();
                }
            }
        }
    }

}

