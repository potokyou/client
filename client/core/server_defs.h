#ifndef SERVER_DEFS_H
#define SERVER_DEFS_H

#include <QObject>
#include "containers/containers_defs.h"

namespace potok {
namespace server {
//QString getContainerName(potok::DockerContainer container);
QString getDockerfileFolder(potok::DockerContainer container);

}
}

#endif // SERVER_DEFS_H
