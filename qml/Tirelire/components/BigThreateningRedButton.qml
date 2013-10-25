// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

Button {
    width: (parent.width - parent.spacing * 2)/ 3;
    height: (parent.height - parent.spacing * 3)/ 4;

    onClicked: {
        if ((text != 'C') && (text != '00')) {
            if (amount < 10000000) {
                amount = amount * 10 + new Number(text);
            }
        } else if (text == '00') {
            if (amount < 10000000) {
                amount = amount * 100;
            }
        } else {
            amount = Math.floor(amount / 10);
        }
    }
}
