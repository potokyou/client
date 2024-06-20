#ifndef SERVERSMODEL_H
#define SERVERSMODEL_H

#include <QAbstractListModel>

#include "settings.h"
#include "core/controllers/serverController.h"

class ServersModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        ServerDescriptionRole,
        CollapsedServerDescriptionRole,
        ExpandedServerDescriptionRole,
        HostNameRole,

        CredentialsRole,
        CredentialsLoginRole,

        IsDefaultRole,
        IsCurrentlyProcessedRole,

        HasWriteAccessRole,

        ContainsPotokDnsRole,

        DefaultContainerRole,

        HasInstalledContainers,
        IsServerFromApiRole,

        HasPotokDns
    };

    ServersModel(std::shared_ptr<Settings> settings, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QVariant data(const int index, int role = Qt::DisplayRole) const;

    void resetModel();

    Q_PROPERTY(int defaultIndex READ getDefaultServerIndex WRITE setDefaultServerIndex NOTIFY defaultServerIndexChanged)
    Q_PROPERTY(QString defaultServerName READ getDefaultServerName NOTIFY defaultServerNameChanged)
    Q_PROPERTY(QString defaultServerDefaultContainerName READ getDefaultServerDefaultContainerName NOTIFY defaultServerDefaultContainerChanged)
    Q_PROPERTY(QString defaultServerDescriptionCollapsed READ getDefaultServerDescriptionCollapsed NOTIFY defaultServerDefaultContainerChanged)
    Q_PROPERTY(QString defaultServerDescriptionExpanded READ getDefaultServerDescriptionExpanded NOTIFY defaultServerDefaultContainerChanged)
    Q_PROPERTY(bool isDefaultServerDefaultContainerHasSplitTunneling READ isDefaultServerDefaultContainerHasSplitTunneling NOTIFY defaultServerDefaultContainerChanged)
    Q_PROPERTY(bool isDefaultServerFromApi READ isDefaultServerFromApi NOTIFY defaultServerIndexChanged)

    Q_PROPERTY(int processedIndex READ getProcessedServerIndex WRITE setProcessedServerIndex NOTIFY processedServerIndexChanged)

public slots:
    void setDefaultServerIndex(const int index);
    const int getDefaultServerIndex();
    const QString getDefaultServerName();
    const QString getDefaultServerDescriptionCollapsed();
    const QString getDefaultServerDescriptionExpanded();
    const QString getDefaultServerDefaultContainerName();
    bool isDefaultServerCurrentlyProcessed();
    bool isDefaultServerFromApi();

    bool isProcessedServerHasWriteAccess();
    bool isDefaultServerHasWriteAccess();
    bool hasServerWithWriteAccess();

    const int getServersCount();

    void setProcessedServerIndex(const int index);
    int getProcessedServerIndex();

    const ServerCredentials getProcessedServerCredentials();
    const ServerCredentials getServerCredentials(const int index);

    void addServer(const QJsonObject &server);
    void editServer(const QJsonObject &server, const int serverIndex);
    void removeServer();

    QJsonObject getServerConfig(const int serverIndex);

    void reloadDefaultServerContainerConfig();
    void updateContainerConfig(const int containerIndex, const QJsonObject config);
    void addContainerConfig(const int containerIndex, const QJsonObject config);

    void clearCachedProfile(const DockerContainer container);

    ErrorCode removeContainer(const QSharedPointer<ServerController> &serverController, const int containerIndex);
    ErrorCode removeAllContainers(const QSharedPointer<ServerController> &serverController);
    ErrorCode rebootServer(const QSharedPointer<ServerController> &serverController);

    void setDefaultContainer(const int serverIndex, const int containerIndex);

    QStringList getAllInstalledServicesName(const int serverIndex);

    void togglePotokDns(bool enabled);
    QPair<QString, QString> getDnsPair(const int serverIndex);

    bool isServerFromApiAlreadyExists(const quint16 crc);

    QVariant getDefaultServerData(const QString roleString);

    QVariant getProcessedServerData(const QString roleString);

    bool isDefaultServerDefaultContainerHasSplitTunneling();

protected:
    QHash<int, QByteArray> roleNames() const override;

signals:
    void processedServerIndexChanged(const int index);
    void defaultServerIndexChanged(const int index);
    void defaultServerNameChanged();
    void defaultServerDescriptionChanged();

    void containersUpdated(const QJsonArray &containers);
    void defaultServerContainersUpdated(const QJsonArray &containers);
    void defaultServerDefaultContainerChanged(const int containerIndex);

private:
    ServerCredentials serverCredentials(int index) const;

    void updateContainersModel();
    void updateDefaultServerContainersModel();

    QString getServerDescription(const QJsonObject &server, const int index) const;

    bool isPotokDnsContainerInstalled(const int serverIndex) const;

    bool serverHasInstalledContainers(const int serverIndex) const;

    QJsonArray m_servers;

    std::shared_ptr<Settings> m_settings;

    int m_defaultServerIndex;
    int m_processedServerIndex;

    bool m_isPotokDnsEnabled = m_settings->usePotokDns();
};

#endif // SERVERSMODEL_H
