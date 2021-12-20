#ifndef APPLICATIONSMODEL_H
#define APPLICATIONSMODEL_H
#include <QAbstractListModel>

class ApplicationItem {
public:
    ApplicationItem(QString title, QString url, QString iconPath);

    QString title() const;

    QString url() const;

    QString iconPath() const;

private:
    QString m_title;
    QString m_url;
    QString m_iconPath;
};

class ApplicationsModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        TitleRole = Qt::UserRole + 1,
        UrlRole,
        IconPathRole
    };
    explicit ApplicationsModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    void addApplication(ApplicationItem &item);
    QList<ApplicationItem> getListApp();
    void copy();
    Q_INVOKABLE void getApp(int index, QString title, QString url, QString iconPath);

protected:
    QHash<int, QByteArray> roleNames() const override;

public slots:
    void swapApplication(int from, int to);

private:
    QList<ApplicationItem> m_data;
    QList<ApplicationItem> m_reorderData;
};

#endif // APPLICATIONSMODEL_H
