#ifndef CONTAINERS_DEFS_H
#define CONTAINERS_DEFS_H

#include <QObject>
#include <QQmlEngine>

#include "../protocols/protocols_defs.h"

using namespace potok;

namespace potok
{

    namespace ContainerEnumNS
    {
        Q_NAMESPACE
        enum DockerContainer {
            None = 0,
            Awg,
            WireGuard,
            OpenVpn,
            Cloak,
            ShadowSocks,
            Ipsec,
            Xray,
            SSXray,

            // non-vpn
            TorWebSite,
            Dns,
            Sftp,
            Socks5Proxy
        };
        Q_ENUM_NS(DockerContainer)
    } // namespace ContainerEnumNS

    using namespace ContainerEnumNS;
    using namespace ProtocolEnumNS;

    class ContainerProps : public QObject
    {
        Q_OBJECT

    public:
        Q_INVOKABLE static potok::DockerContainer containerFromString(const QString &container);
        Q_INVOKABLE static QString containerToString(potok::DockerContainer container);
        Q_INVOKABLE static QString containerTypeToString(potok::DockerContainer c);

        Q_INVOKABLE static QList<potok::DockerContainer> allContainers();

        Q_INVOKABLE static QMap<potok::DockerContainer, QString> containerHumanNames();
        Q_INVOKABLE static QMap<potok::DockerContainer, QString> containerDescriptions();
        Q_INVOKABLE static QMap<potok::DockerContainer, QString> containerDetailedDescriptions();

        // these protocols will be displayed in container settings
        Q_INVOKABLE static QVector<potok::Proto> protocolsForContainer(potok::DockerContainer container);

        Q_INVOKABLE static potok::ServiceType containerService(potok::DockerContainer c);

        // binding between Docker container and main protocol of given container
        // it may be changed fot future containers :)
        Q_INVOKABLE static potok::Proto defaultProtocol(potok::DockerContainer c);

        Q_INVOKABLE static bool isSupportedByCurrentPlatform(potok::DockerContainer c);
        Q_INVOKABLE static QStringList fixedPortsForContainer(potok::DockerContainer c);

        static bool isEasySetupContainer(potok::DockerContainer container);
        static QString easySetupHeader(potok::DockerContainer container);
        static QString easySetupDescription(potok::DockerContainer container);
        static int easySetupOrder(potok::DockerContainer container);

        static bool isShareable(potok::DockerContainer container);

        static QJsonObject getProtocolConfigFromContainer(const potok::Proto protocol, const QJsonObject &containerConfig);
    };

    static void declareQmlContainerEnum()
    {
        qmlRegisterUncreatableMetaObject(ContainerEnumNS::staticMetaObject, "ContainerEnum", 1, 0, "ContainerEnum",
                                         "Error: only enums");
    }

} // namespace potok

QDebug operator<<(QDebug debug, const potok::DockerContainer &c);

#endif // CONTAINERS_DEFS_H
