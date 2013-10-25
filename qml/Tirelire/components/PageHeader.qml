import QtQuick 1.1
import com.nokia.meego 1.0

Rectangle {
    id:header

    property alias title: headerlabel.text
    property real solde: py.total / 100
    property string moneyUnit: '€'

    anchors.top: parent.top
    width:parent.width
    height: 70
    color:'#92a278'
    z:2
    visible: true
    opacity: visible

    Text{
        id:headerlabel
        anchors.right: soldeLabel.left
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 20
        anchors.rightMargin: 10
        font { bold: false; family: "Nokia Pure Text"; pixelSize: 36; }
        color:"white"
        text:'Title'
    }

    Text {
        id: soldeLabel
        font { bold: false; family: "Nokia Pure Text"; pixelSize: 36; }
        color: solde > 0.0 ? "white" : "red";
        text: formatMoney(solde) + ' ' + moneyUnit
        anchors.right: header.right
        anchors.rightMargin: 20
        anchors.verticalCenter: header.verticalCenter
    }
}
