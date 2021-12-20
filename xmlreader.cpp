#include "xmlreader.h"

XmlReader::XmlReader(QString filePath, ApplicationsModel &model)
{
    m_filePath = PROJECT_PATH + filePath;
    m_appModel = &model;
    ReadXmlFile(m_filePath);
    PaserXml(model);
}

bool XmlReader::ReadXmlFile(QString filePath)
{
    // Load xml file as raw data
    QFile f(filePath);
    if (!f.open(QIODevice::ReadOnly ))
    {
        // Error while loading file
        return false;
    }
    // Set data into the QDomDocument before processing
    m_xmlDoc.setContent(&f);
    f.close();
    return true;
}

void XmlReader::PaserXml(ApplicationsModel &model)
{
    // Extract the root markup
    QDomElement root=m_xmlDoc.documentElement();

    // Get the first child of the root (Markup COMPONENT is expected)
    QDomElement Component=root.firstChild().toElement();

    // Loop while there is a child
    while(!Component.isNull())
    {
        // Check if the child tag name is COMPONENT
        if (Component.tagName()=="APP")
        {

            // Read and display the component ID
            QString ID=Component.attribute("ID","No ID");

            // Get the first child of the component
            QDomElement Child=Component.firstChild().toElement();

            QString title;
            QString url;
            QString iconPath;

            // Read each child of the component node
            while (!Child.isNull())
            {
                // Read Name and value
                if (Child.tagName()=="TITLE") title = Child.firstChild().toText().data();
                if (Child.tagName()=="URL") url = Child.firstChild().toText().data();
                if (Child.tagName()=="ICON_PATH") iconPath = Child.firstChild().toText().data();

                // Next child
                Child = Child.nextSibling().toElement();
            }
            ApplicationItem item(title,url,iconPath);
            model.addApplication(item);
        }

        // Next component
        Component = Component.nextSibling().toElement();
    }
    //copy list for reorder
    model.copy();
}

//Open and write xml file
void XmlReader::writeXML() {
    QDomDocument document = dataXML(m_appModel->getListApp());

    QFile file(m_filePath);
    if( !file.open( QIODevice::WriteOnly | QIODevice::Text ) )
    {
        qDebug( "Failed to pen XML file. Please try again!" );
        qDebug() << "ERROR" << file.errorString() << endl;
    }
    QTextStream textStream( &file );
    textStream << document.toString();
    file.close();
}

//Write data in XML file
QDomDocument XmlReader::dataXML(QList<ApplicationItem> list) {
    //list app always start with 1
    int count = 1;

    //Create document to write
    QDomDocument doc;
    //Create root of list app
    QDomElement root = doc.createElement("APPLICATIONS");
    //Add root to document
    doc.appendChild(root);

    //Create application
    foreach (ApplicationItem item , list) {

        //Create ID of application
        QDomElement app = doc.createElement("APP");
        app.setAttribute("ID", "00" + QString::number(count));
        root.appendChild(app);//add to app

        //Create title of application
        QDomElement title = doc.createElement("TITLE");
        title.appendChild(doc.createTextNode(item.title()));//get title of application
        app.appendChild(title);//add title into app

        //Create URL of application
        QDomElement url = doc.createElement("URL");
        url.appendChild(doc.createTextNode(item.url()));//get URL
        app.appendChild(url);//add URL into app

        //Create icon path of application
        QDomElement icon_path = doc.createElement("ICON_PATH");
        icon_path.appendChild(doc.createTextNode(item.iconPath()));//get icon
        app.appendChild(icon_path);//add icon into app

        //increase count for each application done
        count++;
    }

    return doc;
}
