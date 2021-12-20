import QtQuick 2.12
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtQml.Models 2.1

Item {
    id: root
    width: 1920
    height: 1096
    property var homeFocus //save previous focus item
    property string urlPath: ""
    function openApp(url){
        urlPath = url
        parent.push(url)
    }

    function replaceApp(url,urlCurrent){
        if(url != urlCurrent){
            urlPath = url
            parent.replace(url)
        }
    }

    Component.onCompleted: {
        appList.forceActiveFocus()

    }

    onActiveFocusChanged: {
        if(activeFocus && homeFocus){
            console.log("HomeWidget onActiveFocusChanged")
            homeFocus.focus = true
        }
    }

    //display for widget
    ListView {
        id: lvWidget
        spacing: 10
        orientation: ListView.Horizontal
        width: 1920
        height: 570
        interactive: false

        displaced: Transition {
            NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
        }

        onFocusChanged: {
            if(focus){
                lvWidget.focus = true
          }
        }
        onCurrentIndexChanged:{
            lvWidget.currentIndex = index
            console.log("Change index widget " + index)
        }


        model: DelegateModel {
            id: visualModelWidget
            model: ListModel {
                id: widgetModel
                ListElement { type: "map" } //@disable-check M16
                ListElement { type: "climate" } //@disable-check M16
                ListElement { type: "media" } //@disable-check M16
            }

            delegate: DropArea {
                id: delegateRootWidget
                width: 635; height: 570
                keys: ["widget"]

                onEntered: {
                    iconWidget.item.enabled = false
                }

                Keys.onPressed: {
                    console.log("Widget Keys.onPressed")
                    switch(event.key){
                    case Qt.Key_Down:
                        console.log(" Key Down")
                        homeFocus = appList
                        appList.focus = true
                        break;
                    case Qt.Key_Left:
                        lvWidget.decrementCurrentIndex()
                        console.log(lvWidget.currentIndex+" Focus : "+ lvWidget.currentItem.focus)
                        break;
                    case Qt.Key_Right:
                        lvWidget.incrementCurrentIndex()
                        console.log(lvWidget.currentIndex)
                        break;
                    case Qt.Key_Return:
                        if(lvWidget.currentIndex == 0){
                            openApp("qrc:/App/Map/Map.qml")
                            break
                        }
                        if(lvWidget.currentIndex == 1){
                            openApp("qrc:/App/Climate/Climate.qml");
                            break
                        }
                        if(lvWidget.currentIndex == 2){
                            openApp("qrc:/App/Media/Media.qml");
                            break;
                        }else{
                            break;
                        }
                    }
                }


                onActiveFocusChanged: {
                    if(activeFocus){
                        console.log("Widget Active focus")
                        homeFocus = lvWidget
                        iconWidget.item.enabled = true
                        console.log(lvWidget.currentIndex)
                    }else{
                        console.log("Widget Lost Active focus")
                    }
                }

                property int visualIndex: DelegateModel.itemsIndex
                Binding { target: iconWidget; property: "visualIndex"; value: visualIndex }
                onExited: iconWidget.item.enabled = true
                onDropped: {
                    console.log(drop.source.visualIndex)
                }

                Loader {
                    id: iconWidget
                    property int visualIndex: 0
                    width: 635; height: 570
                    anchors {
                        horizontalCenter: parent.horizontalCenter;
                        verticalCenter: parent.verticalCenter
                    }

                    sourceComponent: {
                        switch(model.type) {
                        case "map": return mapWidget
                        case "climate": return climateWidget
                        case "media": return mediaWidget
                        }
                    }

                    Drag.active: iconWidget.item.drag.active
                    Drag.keys: "widget"
                    Drag.hotSpot.x: delegateRootWidget.width/2
                    Drag.hotSpot.y: delegateRootWidget.height/2

                    states: [
                        State {
                            when: iconWidget.Drag.active
                            ParentChange {
                                target: iconWidget
                                parent: root
                            }

                            AnchorChanges {
                                target: iconWidget
                                anchors.horizontalCenter: undefined
                                anchors.verticalCenter: undefined
                            }
                        }
                    ]
                }
            }
        }

        Component {
            id: mapWidget
            MapWidget{
                onClicked: {
                    homeFocus = lvWidget
                    lvWidget.focus = true
                    openApp("qrc:/App/Map/Map.qml")
                    lvWidget.currentIndex = 0
                }
                isFocus: lvWidget.currentIndex == 0 && lvWidget.focus
            }
        }
        Component {
            id: climateWidget
            ClimateWidget {
                onClicked: {
                    //when focus widget then set app not focus
                    homeFocus = lvWidget
                    lvWidget.focus = true
                    lvWidget.currentIndex = 1
                    openApp("qrc:/App/Climate/Climate.qml");
                }
                isFocus: lvWidget.currentIndex == 1 && lvWidget.focus
            }
        }
        Component {
            id: mediaWidget
            MediaWidget{
                onClicked:{
                    homeFocus = lvWidget
                    //when focus widget then set app not focus
                    lvWidget.focus = true
                    lvWidget.currentIndex = 2
                    openApp("qrc:/App/Media/Media.qml")
                }
                isFocus: lvWidget.currentIndex == 2 && lvWidget.focus
            }
        }

    }

    //Display for application
    ListView {
        id:appList
        x: 0
        y:570
        width: 1920; height: 526
        orientation: ListView.Horizontal
        interactive: appList.count > 6
        focus: true;
        spacing: 5
        displaced: Transition {
            NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
        }

        model: visualModel
        onCurrentItemChanged: {
            console.log(visualModel.items.get(currentIndex).model.title)

        }

        ScrollBar.horizontal : ScrollBar{
            policy: ScrollBar.AlwaysOn
            active: ScrollBar.AlwaysOn
            anchors.bottom: parent.top
        }
        onFocusChanged: {
            console.log("ListView----> Focus: "+focus)
            if(!focus){
                appList.currentItem.appItem.focus = false
                appList.currentItem.appItem.state = "Normal"
            }else {
                appList.currentItem.appItem.focus = true
                appList.currentItem.appItem.state = "Focus"
            }
        }

    DelegateModel {
        id: visualModel
        model: appsModel
        delegate: DropArea {
            id: delegateRoot
            width: 316; height: 526
            keys: "AppButton"
            onEntered: {
                visualModel.items.move(drag.source.visualIndex, icon.visualIndex)
                console.log("Changes from " + drag.source.visualIndex + " - " + icon.visualIndex)
                delegateRoot.drag
            }
            onDropped: {
                console.log("Droped")
            }

            onExited: {
                icon.item.enabled = true
                appList.focus= true
            }

            Keys.onPressed: {
                console.log("App Keys.onPressed")
                switch(event.key){
                case Qt.Key_Up:
                    console.log("App Key UP")
                    homeFocus = lvWidget
                    lvWidget.focus = true
                    break;
                case Qt.Key_Enter:
                case Qt.Key_Return:
                    openApp("qrc:/App/"+app.title+"/"+app.title+".qml")
                    break;
                }
            }
            onActiveFocusChanged: {
                if(activeFocus){
                    console.log("App Active focus")
                    app.focus = true
                    app.state = "Focus"
                }else{
                    console.log("App Lost Active focus")
                }
            }

            property int visualIndex: DelegateModel.itemsIndex
            property alias appItem: app
            Binding { target: icon; property: "visualIndex"; value: visualIndex }
            Item {
                id: icon
                property int visualIndex: 0
                width: 316; height: 526
                anchors {
                    horizontalCenter: parent.horizontalCenter;
                    verticalCenter: parent.verticalCenter
                }

                AppButton{
                    id: app
                    anchors.fill: parent
                    title: model.title
                    icon: model.iconPath

                    //move application
                    property bool isDraging: false
                    drag.axis: Drag.XAxis
                    drag.target: isDraging ? icon : "undefined"

                    onPressAndHold: {
                        isDraging = true //800ms
                    }
                    onPressed: {
                        var temp_listApp = []
                        app.focus = true
                        app.state = "Focus"
                        appList.focus = true
                        homeFocus = appList
                        for (var index = 0; index < visualModel.items.count;index++){
                            if (index !== icon.visualIndex)
                                visualModel.items.get(index).focus = false
                            else
                                visualModel.items.get(index).focus = true
                            //add app item into temp list after reorder
                            temp_listApp [index] = visualModel.items.get(index).model
                            //get app
                            appsModel.getApp(index,temp_listApp [index].title,temp_listApp [index].url,temp_listApp [index].iconPath)
                        }
                        //write xml file
                        XMLHandler.writeXML()

                    }
                    onReleased: {
                        if(!isDraging){
                            console.log("Index app " + index)
                            openApp("qrc:/App/"+app.title+"/"+app.title+".qml")
                            appList.currentIndex = index

                        }else{
                            console.log("Current index " + appList.currentIndex + ": Index App "+ index)
                        }

                        isDraging = false //finish drag
                    }
                }

                onFocusChanged: {
                    app.focus = icon.focus
                }


                Drag.active: app.isDraging  //drag active when press and hold
                Drag.source: icon
                Drag.hotSpot.x:width/2
                Drag.hotSpot.y:height/2
                Drag.keys: "AppButton"

                states: [
                    State {
                        when: icon.Drag.active
                        ParentChange {
                            target: icon
                            parent: appList
                        }

                        AnchorChanges {
                            target: icon
                            anchors.horizontalCenter: undefined
                            anchors.verticalCenter: undefined
                        }
                    }
                ]
            }
        }
    }
}
}
