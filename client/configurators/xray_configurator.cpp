#include "xray_configurator.h"

#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>

#include "containers/containers_defs.h"
#include "core/controllers/serverController.h"
#include "core/scripts_registry.h"

XrayConfigurator::XrayConfigurator(std::shared_ptr<Settings> settings, const QSharedPointer<ServerController> &serverController, QObject *parent)
    : ConfiguratorBase(settings, serverController, parent)
{
}

QString XrayConfigurator::createConfig(const ServerCredentials &credentials, DockerContainer container, const QJsonObject &containerConfig,
                                       ErrorCode &errorCode)
{
    QString config = m_serverController->replaceVars(potok::scriptData(ProtocolScriptType::xray_template, container),
                                                     m_serverController->genVarsForScript(credentials, container, containerConfig));

    QString xrayPublicKey =
            m_serverController->getTextFileFromContainer(container, credentials, potok::protocols::xray::PublicKeyPath, errorCode);
    xrayPublicKey.replace("\n", "");

    QString xrayUuid = m_serverController->getTextFileFromContainer(container, credentials, potok::protocols::xray::uuidPath, errorCode);
    xrayUuid.replace("\n", "");

    QString xrayShortId =
            m_serverController->getTextFileFromContainer(container, credentials, potok::protocols::xray::shortidPath, errorCode);
    xrayShortId.replace("\n", "");

    if (errorCode != ErrorCode::NoError) {
        return "";
    }

    config.replace("$XRAY_CLIENT_ID", xrayUuid);
    config.replace("$XRAY_PUBLIC_KEY", xrayPublicKey);
    config.replace("$XRAY_SHORT_ID", xrayShortId);

    return config;
}
