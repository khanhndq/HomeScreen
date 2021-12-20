import QtQuick 2.11
import QtQuick.Window 2.0
import QtQuick.Controls 2.4

ApplicationWindow {
    id: window
    visible: true
    width: 1920
    height: 1200
    property string urlCheck: ""
    Image {
        id: background
        width: 1920
        height: 1200
        source: "qrc:/Img/bg_full.png"
    }

    StatusBar {
        id: statusBar
        onBntBackClicked: stackView.pop()
        onBntBackClicked1: stackView.pop()
        isShowBackBtn: stackView.depth == 1 ? false : true//depth is check how many item

    }

    StackView {
        id: stackView
        width: 1920
        anchors.top: statusBar.bottom
        initialItem: HomeWidget{
            id: home
        }//display first window
        onCurrentItemChanged: {
            currentItem.forceActiveFocus()
        }
        pushExit: Transition {
            XAnimator {
                from: 0
                to: -1920
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        onFocusChanged: {
            console.log("VIEW focus changes: " + focus)
        }
        onDepthChanged: {
            console.log("onDepthChanged: " +  stackView.depth)
            if(stackView.depth == 1){
                if(activeFocus && home.homeFocus){
                    home.homeFocus.focus = true
                    console.log(home.homeFocus.focus)

                }

            }
        }

        Keys.onPressed: {
            console.log("MAIN key press")
            switch(event.key){
            case Qt.Key_Backspace:
                console.log("HK BACK")
                stackView.pop()
                if(activeFocus && home.homeFocus){
                    console.log("Keep old focus")
                    home.homeFocus.focus = true
                }
                break;
                //Shortcut
            case Qt.Key_1:
                if(stackView.depth == 1){
                    home.openApp("qrc:/App/Map/Map.qml");
                    urlCheck = "qrc:/App/Map/Map.qml"
                } else { //not Home screen
                    home.replaceApp("qrc:/App/Map/Map.qml", urlCheck)
                    urlCheck = "qrc:/App/Map/Map.qml"
                }

                break;
            case Qt.Key_2:
                if(stackView.depth == 1){
                    home.openApp("qrc:/App/Climate/Climate.qml");
                    urlCheck = "qrc:/App/Climate/Climate.qml"
                } else { //not Home screen
                    home.replaceApp("qrc:/App/Climate/Climate.qml", urlCheck);
                    urlCheck = "qrc:/App/Climate/Climate.qml"
                }

                break;
            case Qt.Key_3:
                if(stackView.depth == 1){
                    home.openApp("qrc:/App/Media/Media.qml")
                    urlCheck = "qrc:/App/Media/Media.qml"
                } else { //not Home screen
                    home.replaceApp("qrc:/App/Media/Media.qml", urlCheck)
                    urlCheck = "qrc:/App/Media/Media.qml"
                }

                break;


        }

    }
}
}
