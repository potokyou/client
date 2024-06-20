#ifndef SETTINGSCONTROLLER_H
#define SETTINGSCONTROLLER_H

#include <QObject>

#include "ui/models/containers_model.h"
#include "ui/models/languageModel.h"
#include "ui/models/servers_model.h"
#include "ui/models/sites_model.h"
#include "ui/models/appSplitTunnelingModel.h"

class SettingsController : public QObject
{
    Q_OBJECT
public:
    explicit SettingsController(const QSharedPointer<ServersModel> &serversModel,
                                const QSharedPointer<ContainersModel> &containersModel,
                                const QSharedPointer<LanguageModel> &languageModel,
                                const QSharedPointer<SitesModel> &sitesModel,
                                const QSharedPointer<AppSplitTunnelingModel> &appSplitTunnelingModel,
                                const std::shared_ptr<Settings> &settings, QObject *parent = nullptr);

    Q_PROPERTY(QString primaryDns READ getPrimaryDns WRITE setPrimaryDns NOTIFY primaryDnsChanged)
    Q_PROPERTY(QString secondaryDns READ getSecondaryDns WRITE setSecondaryDns NOTIFY secondaryDnsChanged)
    Q_PROPERTY(bool isLoggingEnabled READ isLoggingEnabled WRITE toggleLogging NOTIFY loggingStateChanged)
    Q_PROPERTY(bool isNotificationPermissionGranted READ isNotificationPermissionGranted NOTIFY onNotificationStateChanged)

public slots:
    void togglePotokDns(bool enable);
    bool isPotokDnsEnabled();

    QString getPrimaryDns();
    void setPrimaryDns(const QString &dns);

    QString getSecondaryDns();
    void setSecondaryDns(const QString &dns);

    bool isLoggingEnabled();
    void toggleLogging(bool enable);

    void openLogsFolder();
    void exportLogsFile(const QString &fileName);
    void clearLogs();

    void backupAppConfig(const QString &fileName);
    void restoreAppConfig(const QString &fileName);
    void restoreAppConfigFromData(const QByteArray &data);

    QString getAppVersion();

    void clearSettings();

    bool isAutoConnectEnabled();
    void toggleAutoConnect(bool enable);

    bool isAutoStartEnabled();
    void toggleAutoStart(bool enable);

    bool isStartMinimizedEnabled();
    void toggleStartMinimized(bool enable);

    bool isScreenshotsEnabled();
    void toggleScreenshotsEnabled(bool enable);

    bool isCameraPresent();

    bool isKillSwitchEnabled();
    void toggleKillSwitch(bool enable);

    bool isNotificationPermissionGranted();
    void requestNotificationPermission();

signals:
    void primaryDnsChanged();
    void secondaryDnsChanged();
    void loggingStateChanged();

    void restoreBackupFinished();
    void changeSettingsFinished(const QString &finishedMessage);
    void changeSettingsErrorOccurred(const QString &errorMessage);

    void saveFile(const QString &fileName, const QString &data);

    void importBackupFromOutside(QString filePath);

    void potokDnsToggled(bool enable);

    void loggingDisableByWatcher();

    void onNotificationStateChanged();

private:
    QSharedPointer<ServersModel> m_serversModel;
    QSharedPointer<ContainersModel> m_containersModel;
    QSharedPointer<LanguageModel> m_languageModel;
    QSharedPointer<SitesModel> m_sitesModel;
    QSharedPointer<AppSplitTunnelingModel> m_appSplitTunnelingModel;
    std::shared_ptr<Settings> m_settings;

    QString m_appVersion;

    QDateTime m_loggingDisableDate;

    void checkIfNeedDisableLogs();
};

#endif // SETTINGSCONTROLLER_H
