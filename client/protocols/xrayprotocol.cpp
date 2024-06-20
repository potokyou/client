#include "xrayprotocol.h"

#include "utilities.h"
#include "containers/containers_defs.h"
#include "core/networkUtilities.h"

#include <QCryptographicHash>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkInterface>


XrayProtocol::XrayProtocol(const QJsonObject &configuration, QObject *parent):
    VpnProtocol(configuration, parent)
{
    readXrayConfiguration(configuration);
    m_routeGateway = NetworkUtilities::getGatewayAndIface();
    m_vpnGateway = potok::protocols::xray::defaultLocalAddr;
    m_vpnLocalAddress = potok::protocols::xray::defaultLocalAddr;
}

XrayProtocol::~XrayProtocol()
{
    XrayProtocol::stop();
    QThread::msleep(200);
    m_xrayProcess.close();
}

ErrorCode XrayProtocol::start()
{
    qDebug().noquote() << "XrayProtocol xrayExecPath():" << xrayExecPath();

    if (!QFileInfo::exists(xrayExecPath())) {
        setLastError(ErrorCode::XrayExecutableMissing);
        return lastError();
    }

    if (Utils::processIsRunning(Utils::executable(xrayExecPath(), true))) {
        Utils::killProcessByName(Utils::executable(xrayExecPath(), true));
    }

#ifdef QT_DEBUG
    m_xrayCfgFile.setAutoRemove(false);
#endif
    m_xrayCfgFile.open();
    m_xrayCfgFile.write(QJsonDocument(m_xrayConfig).toJson());
    m_xrayCfgFile.close();

    QStringList args = QStringList() << "-c" << m_xrayCfgFile.fileName() << "-format=json";

    qDebug().noquote() << "XrayProtocol::start()"
                       << xrayExecPath() << args.join(" ");

    m_xrayProcess.setProcessChannelMode(QProcess::MergedChannels);

    m_xrayProcess.setProgram(xrayExecPath());
    m_xrayProcess.setArguments(args);

    connect(&m_xrayProcess, &QProcess::readyReadStandardOutput, this, [this]() {
#ifdef QT_DEBUG
        qDebug().noquote() << "xray:" << m_xrayProcess.readAllStandardOutput();
#endif
    });

    connect(&m_xrayProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this, [this](int exitCode, QProcess::ExitStatus exitStatus) {
        qDebug().noquote() << "XrayProtocol finished, exitCode, exiStatus" << exitCode << exitStatus;
        setConnectionState(Vpn::ConnectionState::Disconnected);
        if (exitStatus != QProcess::NormalExit) {
            emit protocolError(potok::ErrorCode::XrayExecutableCrashed);
            stop();
        }
        if (exitCode != 0) {
            emit protocolError(potok::ErrorCode::InternalError);
            stop();
        }
    });

    m_xrayProcess.start();
    m_xrayProcess.waitForStarted();

    if (m_xrayProcess.state() == QProcess::ProcessState::Running) {
        setConnectionState(Vpn::ConnectionState::Connecting);
        QThread::msleep(1000);
        return startTun2Sock();
    }
    else return ErrorCode::XrayExecutableMissing;
}


ErrorCode XrayProtocol::startTun2Sock()
{
    if (!QFileInfo::exists(Utils::tun2socksPath())) {
        setLastError(ErrorCode::Tun2SockExecutableMissing);
        return lastError();
    }

    m_t2sProcess = IpcClient::CreatePrivilegedProcess();

    if (!m_t2sProcess) {
        setLastError(ErrorCode::PotokServiceConnectionFailed);
        return ErrorCode::PotokServiceConnectionFailed;
    }

    m_t2sProcess->waitForSource(1000);
    if (!m_t2sProcess->isInitialized()) {
        qWarning() << "IpcProcess replica is not connected!";
        setLastError(ErrorCode::PotokServiceConnectionFailed);
        return ErrorCode::PotokServiceConnectionFailed;
    }

    QString XrayConStr = "socks5://127.0.0.1:" + QString::number(m_localPort);

    m_t2sProcess->setProgram(PermittedProcess::Tun2Socks);
#ifdef Q_OS_WIN
    m_configData.insert("inetAdapterIndex", NetworkUtilities::AdapterIndexTo(QHostAddress(m_remoteAddress)));
    QStringList arguments({"-device", "tun://tun2", "-proxy", XrayConStr, "-tun-post-up",
                           QString("cmd /c netsh interface ip set address name=\"tun2\" static %1 255.255.255.255").arg(potok::protocols::xray::defaultLocalAddr)});
#endif
#ifdef Q_OS_LINUX
    QStringList arguments({"-device", "tun://tun2", "-proxy", XrayConStr});
#endif
#ifdef Q_OS_MAC
    QStringList arguments({"-device", "utun22", "-proxy", XrayConStr});
#endif
    m_t2sProcess->setArguments(arguments);

    qDebug() << arguments.join(" ");
    connect(m_t2sProcess.data(), &PrivilegedProcess::errorOccurred,
            [&](QProcess::ProcessError error) { qDebug() << "PrivilegedProcess errorOccurred" << error; });

    connect(m_t2sProcess.data(), &PrivilegedProcess::stateChanged,
            [&](QProcess::ProcessState newState) {
                qDebug() << "PrivilegedProcess stateChanged" << newState;
        if (newState == QProcess::Running)
        {
            setConnectionState(Vpn::ConnectionState::Connecting);
            QList<QHostAddress> dnsAddr;
            dnsAddr.push_back(QHostAddress(m_configData.value(config_key::dns1).toString()));
            dnsAddr.push_back(QHostAddress(m_configData.value(config_key::dns2).toString()));

#ifdef Q_OS_MACOS
            QThread::msleep(5000);
            IpcClient::Interface()->createTun("utun22", potok::protocols::xray::defaultLocalAddr);
            IpcClient::Interface()->updateResolvers("utun22", dnsAddr);
#endif
#ifdef Q_OS_WINDOWS
            QThread::msleep(15000);
#endif
#ifdef Q_OS_LINUX
            QThread::msleep(1000);
            IpcClient::Interface()->createTun("tun2", potok::protocols::xray::defaultLocalAddr);
            IpcClient::Interface()->updateResolvers("tun2", dnsAddr);
#endif
#if defined(Q_OS_LINUX) || defined(Q_OS_MACOS)
            // killSwitch toggle
            if (QVariant(m_configData.value(config_key::killSwitchOption).toString()).toBool()) {
                IpcClient::Interface()->enableKillSwitch(m_configData, 0);
            }
#endif
            if (m_routeMode == 0) {
                IpcClient::Interface()->routeAddList(m_vpnGateway, QStringList() << "0.0.0.0/1");
                IpcClient::Interface()->routeAddList(m_vpnGateway, QStringList() << "128.0.0.0/1");
                IpcClient::Interface()->routeAddList(m_routeGateway, QStringList() << m_remoteAddress);
            }
            IpcClient::Interface()->StopRoutingIpv6();
#ifdef Q_OS_WIN
            IpcClient::Interface()->updateResolvers("tun2", dnsAddr);
            QList<QNetworkInterface> netInterfaces = QNetworkInterface::allInterfaces();
            for (int i = 0; i < netInterfaces.size(); i++) {
                for (int j=0; j < netInterfaces.at(i).addressEntries().size(); j++)
                {
                    // killSwitch toggle
                    if (m_vpnLocalAddress == netInterfaces.at(i).addressEntries().at(j).ip().toString()) {
                        if (QVariant(m_configData.value(config_key::killSwitchOption).toString()).toBool()) {
                            IpcClient::Interface()->enableKillSwitch(QJsonObject(), netInterfaces.at(i).index());
                        }
                        m_configData.insert("vpnAdapterIndex", netInterfaces.at(i).index());
                        m_configData.insert("vpnGateway", m_vpnGateway);
                        m_configData.insert("vpnServer", m_remoteAddress);
                        IpcClient::Interface()->enablePeerTraffic(m_configData);
                    }
                }
            }
#endif
            setConnectionState(Vpn::ConnectionState::Connected);
        }
    });


#if !defined(Q_OS_MACOS)
    connect(m_t2sProcess.data(), &PrivilegedProcess::finished, this,
            [&]() {
                setConnectionState(Vpn::ConnectionState::Disconnected);
                IpcClient::Interface()->deleteTun("tun2");
                IpcClient::Interface()->StartRoutingIpv6();
                IpcClient::Interface()->clearSavedRoutes();
    });
#endif

    m_t2sProcess->start();


    return ErrorCode::NoError;
}

void XrayProtocol::stop()
{
#if defined(Q_OS_WIN) || defined(Q_OS_LINUX) || defined(Q_OS_MACOS)
    IpcClient::Interface()->disableKillSwitch();
    IpcClient::Interface()->StartRoutingIpv6();
#endif
    qDebug() << "XrayProtocol::stop()";
    m_xrayProcess.terminate();
    if (m_t2sProcess) {
        m_t2sProcess->close();
    }

#ifdef Q_OS_WIN
    Utils::signalCtrl(m_xrayProcess.processId(), CTRL_C_EVENT);
#endif
}

QString XrayProtocol::xrayExecPath()
{
#ifdef Q_OS_WIN
    return Utils::executable(QString("xray/xray"), true);
#else
    return Utils::executable(QString("xray"), true);
#endif
}

void XrayProtocol::readXrayConfiguration(const QJsonObject &configuration)
{
    m_configData = configuration;
    QJsonObject xrayConfiguration = configuration.value(ProtocolProps::key_proto_config_data(Proto::Xray)).toObject();
    if (xrayConfiguration.isEmpty()) {
        xrayConfiguration = configuration.value(ProtocolProps::key_proto_config_data(Proto::SSXray)).toObject();
    }
    m_xrayConfig = xrayConfiguration;
    m_localPort = QString(potok::protocols::xray::defaultLocalProxyPort).toInt();
    m_remoteAddress = configuration.value(potok::config_key::hostName).toString();
    m_routeMode = configuration.value(potok::config_key::splitTunnelType).toInt();
    m_primaryDNS = configuration.value(potok::config_key::dns1).toString();
    m_secondaryDNS = configuration.value(potok::config_key::dns2).toString();
}
