#ifndef XMLREADER_H
#define XMLREADER_H
#include <QtXml>
#include <QFile>
#include "applicationsmodel.h"

class XmlReader :public QObject
{
    Q_OBJECT
public:
    XmlReader(QString filePath, ApplicationsModel &model);
private:
    QDomDocument m_xmlDoc; //The QDomDocument class represents an XML document.
    QString m_filePath;
    ApplicationsModel *m_appModel;
    bool ReadXmlFile(QString filePath);
    void PaserXml(ApplicationsModel &model);
    QDomDocument dataXML(QList<ApplicationItem> list);
public slots:
    void writeXML();
};

#endif // XMLREADER_H
