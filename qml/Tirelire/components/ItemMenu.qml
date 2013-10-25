import QtQuick 1.1
import com.nokia.meego 1.0

Menu {
    id: itemMenu
    visualParent: pageStack

    property string uid

    MenuLayout {
        MenuItem {
            text: qsTr("Duplicate")
            onClicked: pyNotes.duplicate(uid);
        }
        MenuItem {
            text: qsTr("Delete")
            onClicked: {
                deleteQueryDialog.uid = uid;
                deleteQueryDialog.open();
            }
        }
    }
}
