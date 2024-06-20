#ifndef QML_REGISTER_PROTOCOLS_H
#define QML_REGISTER_PROTOCOLS_H

#include "protocols_defs.h"

#include <QObject>
#include <QDebug>
#include <QQmlEngine>

namespace potok {

using namespace potok::ProtocolEnumNS;

void declareQmlProtocolEnum() {
    qmlRegisterUncreatableMetaObject(
        ProtocolEnumNS::staticMetaObject,
        "ProtocolEnum",
        1, 0,
        "ProtocolEnum",
        "Error: only enums"
        );

    qmlRegisterUncreatableMetaObject(
        ProtocolEnumNS::staticMetaObject,
        "ProtocolEnum",
        1, 0,
        "TransportProto",
        "Error: only enums"
        );

    qmlRegisterUncreatableMetaObject(
        ProtocolEnumNS::staticMetaObject,
        "ProtocolEnum",
        1, 0,
        "ServiceType",
        "Error: only enums"
        );
}

} // namespace potok

QDebug operator<<(QDebug debug, const potok::Proto &p);

#endif // QML_REGISTER_PROTOCOLS_H
