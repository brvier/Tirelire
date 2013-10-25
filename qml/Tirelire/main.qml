import QtQuick 1.1
import com.nokia.meego 1.0
import net.khertan.python 1.0

PageStackWindow {
    id: appWindow

    property string version: '1.0.0'
    property string description: 'A fast, easy to use, and simple expenses tracker'

                                 + '<br><br>By Benoît HERVIER'
                                 + '<br>WebSite : <a href="http://khertan.net/">http://khertan.net/tirelire</a>'
                                 + '<br><b>Licenced under GPLv3'
                                 + '<br>Donate in Bitcoin : <a href="bitcoin://1Khertan7mpfbabM531QTsnDXBdK7sDYxL">1Khertan7mpfbabM531QTsnDXBdK7sDYxL</a>'

    property string changelogs: '<br><b>1.0.0 :</b><br>* Initial public release'

    initialPage: mainPage

    Python {
        id: pyCat

        function listCategories() {
            threadedCall('tirelire.getCategories', []);
        }

        Component.onCompleted: {
            addImportPath('/opt/Tirelire/python');
            importModule('tirelire');
            //listCategories();
        }
    }

    Python {
        id: py
        signal requireRefresh
        property int total: 0

        function listExpenses(startDate, endDate) {
            threadedCall('tirelire.listExpenses', [startDate, endDate]);
        }

        function insertOrUpdate(uid, date, desc, amount) {
            if (call('tirelire.insertOrUpdate', [uid, desc, amount, date])) {
                requireRefresh();
            }
        }

        function remove(uid) {
            if (call('tirelire.rm', [uid, ]))
                requireRefresh();
        }

        function getTotal() {
            var total = call('tirelire.getTotal', []);
        }

        onMessage: {
            total = data[0]
        }

        Component.onCompleted: {
            addImportPath('/opt/Tirelire/python');
            importModule('tirelire');
            requireRefresh();
        }

        onException: {
            console.log('Exception:'+type+':'+data);
        }

        onFinished: {
            console.log('Finished')
        }
    }

    MainPage {
        id: mainPage
    }

    function formatMoney(value) {
        var DecimalSeparator = Number("1.2").toLocaleString().substr(1,1);


        var AmountWithCommas = value.toLocaleString();
        var arParts = String(AmountWithCommas).split(DecimalSeparator);
        var intPart = arParts[0];
        var decPart = (arParts.length > 1 ? arParts[1] : '');
        decPart = (decPart + '00').substr(0,2);


        return intPart + DecimalSeparator + decPart;
    }


}
