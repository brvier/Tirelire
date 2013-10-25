import QtQuick 1.1
import com.nokia.meego 1.0
import "components"

Page {
    tools: commonTools
    objectName: 'listPage'
    property string sectionCriteria : "date"

    function dateStringFromTimestamp(timestamp) {
        var d = new Date();
        d.setTime(timestamp * 1000);
        return Qt.formatDate(d);
    }

    PageHeader {
        title:'Tirelire'
        id: pageHeader
    }

    ListModel {
        id: expensesModel
        property int startDate: 0
        property int endDate: 0

        function fill(data) {
            expensesModel.clear();
            for (var i=0; i<data.length; i++) {
                expensesModel.append(data[i]);
            }
        }

        Component.onCompleted: {
            if (startDate === 0) {
                var d = new Date();                
                startDate = getStartMonth(d)
                console.log('StartDate : ' + startDate)
            }
            if (endDate === 0) {
                var d = new Date();
                endDate = getEndMonth(d);
            }

        }

    }

    Connections {
        target: py
        onMessage: {
            expensesModel.fill(data[1]);
        }
        onRequireRefresh: {
            console.log('StartDate RequireRefresh: ' + expensesModel.startDate);
            console.log('EndDate RequireRefresh: ' + expensesModel.endDate);
            py.listExpenses(expensesModel.startDate,
                            expensesModel.endDate);
        }
    }

    Component {
        id: expensesSection
        Rectangle {
            width: expensesView.width
            height: 40
            color: "#b4d480"

            Label {
                text: (sectionCriteria === "date") ? dateStringFromTimestamp(section) : section;
                font.bold: true
                font.family: "Nokia Pure Text"
                font.pixelSize: 18
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.fill: parent
             }
        }
    }

    ListView {
        id: expensesView
        anchors.top: pageHeader.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        model: expensesModel

        delegate:
            Rectangle {
            anchors {
                left: parent.left
                right: parent.right              
            }
            height: Math.max(50, expensesInfos.height + 20)
            color: index % 2 === 0 ? "white" : "#f5f5ff"

            Rectangle {
                id: background
                anchors.fill: parent
                color: "darkgray";
                opacity: 0.0
                Behavior on opacity { NumberAnimation {} }                
            }

            MouseArea {
                anchors.fill: parent
                onPressed: background.opacity = 1.0;
                onReleased: background.opacity = 0.0;
                onPositionChanged: background.opacity = 0.0;
                onClicked: {
                    var editingPage = Qt.createComponent(Qt.resolvedUrl("EditPage.qml"));
                    pageStack.push(editingPage, {uid: model.uid,
                                                 amount: Math.abs(model.amount),
                                                 date: date,
                                                 desc: model.desc,
                                                 positive: (model.amount >= 0) ? true : false});
                }
            }

            Row {
                id:expensesInfos
                spacing: 5
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 20
                    rightMargin: 20
                    topMargin: 10
                    top: parent.top
                    bottom: parent.bottom
                    bottomMargin: 10
                }


                Column {
                    id: expensesRow
                    spacing: 5
                    width: parent.width - expensesAmount.width - 5
                    anchors.verticalCenter: parent.verticalCenter
                    Label {
                        text: (sectionCriteria === "date") ? desc : dateStringFromTimestamp(date);
                        font.family: "Nokia Pure Text"
                        font.pixelSize: 24
                        color:"#333366"
                    }

                    /*Label {
                        text: Date().setTime(date).toLocalDateString()
                        font.pixelSize: 18
                        color: "#666666"
                    }*/

                }


                Label {
                    id: expensesAmount
                    text: formatMoney(amount/100)
                    height: expensesRow.height
                    color: amount < 0 ? 'black' : 'green'
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: expensesRow.verticalCenter
                }

            }
        }
        section.property: sectionCriteria
        section.criteria: ViewSection.FullString
        section.delegate: expensesSection

    }

    SectionScroller {
        id:sectionScroller
        listView: expensesView
        z:4
    }

    ScrollDecorator {
        id: scrollDecorator
        flickableItem: expensesView
        z:3
        platformStyle: ScrollDecoratorStyle {
        }
    }

    QueryDialog {

        property string uid

        id: deleteQueryDialog
        icon: Qt.resolvedUrl('../../icons/Tirelire.svg')
        titleText: "Delete"
        message: "Are you sure you want to delete this expense ?"
        acceptButtonText: qsTr("Delete")
        rejectButtonText: qsTr("Cancel")
        onAccepted: {
            py.remove(uid);
            pageStack.pop();
        }
    }


    MonthPickerDialog{
        id:monthPickerDialog
        titleText: "Select Month"
        parent: mainPage
        onAccepted: {monthPickerAccepted()}
    }


    ToolBarLayout {
        id: commonTools
        visible: true
        ToolIcon {
            id: toolbarAdd
            platformIconId: "toolbar-add"
            anchors.left: (parent === undefined) ? undefined : parent.left
            onClicked: {
                var editPage = Qt.createComponent(Qt.resolvedUrl('EditPage.qml'));
                var d = new Date()
                pageStack.push(editPage, {date: new Date().getTime() / 1000})
            }
        }
        ToolIcon {
            platformIconId: "toolbar-history"
            onClicked: {
                var d = new Date();
                if (expensesModel.startDate !== 0) {
                    d.setTime(expensesModel.startDate * 1000);
                }
                monthPickerDialog.year = d.getFullYear();
                monthPickerDialog.month = d.getMonth() + 1;
                monthPickerDialog.open();
            }
        }

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: (mainMenu.status === DialogStatus.Closed) ? mainMenu.open() : mainMenu.close()
        }
    }

    function monthPickerAccepted(){
        var ddate = new Date();
        ddate.setMonth(monthPickerDialog.month - 1);
        ddate.setYear(monthPickerDialog.year);
        ddate.setDate(1);
        expensesModel.startDate = getStartMonth(ddate);
        expensesModel.endDate = getEndMonth(ddate);
        py.listExpenses(expensesModel.startDate,
                        expensesModel.endDate);
        //date = Math.round((ddate.getTime() / 1000));
        //dateField.text = Qt.formatDate(ddate);
    }

    function getStartMonth(d) {
            d.setHours(0);
            d.setMinutes(0);
            d.setSeconds(0);
            d.setMilliseconds(0);
            d.setDate(1);
            return Math.round((d.getTime() / 1000));
    }

    function getEndMonth(d) {
            d.setHours(23);
            d.setMinutes(59);
            d.setSeconds(59);
            d.setMilliseconds(999);
            d.setMonth(d.getMonth() + 1);
            d.setDate(0);
            return Math.round((d.getTime() / 1000))
    }

    Menu {
        id: mainMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem {
                text: qsTr("About");
                onClicked: {
                    var aboutPage = Qt.createComponent(Qt.resolvedUrl('components/AboutPage.qml'))
                    pageStack.push(aboutPage, {title: 'Tirelire',
                                               slogan: 'Version '+version,
                                               iconSource: Qt.resolvedUrl('../../icons/Tirelire.svg'),
                                               text: description + '<br><br><b>Changelog</b><br><br>'+changelogs})
                }
            }
            MenuItem {
                text: qsTr("Order by Desc/Date");
                onClicked: {
                    sectionCriteria = (sectionCriteria === "date") ? "desc" : "date";
                }
            }
        }
    }

    //State used to detect when we should refresh view
    states: [
        State {
            name: "fullsize-visible"
            when: platformWindow.viewMode === WindowState.Fullsize && platformWindow.visible
            StateChangeScript {
                script: {
                    if (pageStack.currentPage.objectName === 'listPage') {
                        py.listExpenses(expensesModel.startDate,
                                        expensesModel.endDate);
                    }
                }
            }
        }
    ]

}


