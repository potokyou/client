#include "server_defs.h"

//QString potok::containerToString(potok::DockerContainer container)
//{
//    switch (container) {
//    case(DockerContainer::OpenVpn): return "potok-openvpn";
//    case(DockerContainer::OpenVpnOverCloak): return "potok-openvpn-cloak";
//    case(DockerContainer::OpenVpnOverShadowSocks): return "potok-shadowsocks";
//    default: return "";
//    }
//}

QString potok::server::getDockerfileFolder(potok::DockerContainer container)
{
    return "/opt/potok/" + ContainerProps::containerToString(container);
}
