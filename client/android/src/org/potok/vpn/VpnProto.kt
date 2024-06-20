package org.potok.vpn

import org.potok.vpn.protocol.Protocol
import org.potok.vpn.protocol.awg.Awg
import org.potok.vpn.protocol.cloak.Cloak
import org.potok.vpn.protocol.openvpn.OpenVpn
import org.potok.vpn.protocol.wireguard.Wireguard
import org.potok.vpn.protocol.xray.Xray

enum class VpnProto(
    val label: String,
    val processName: String,
    val serviceClass: Class<out PotokVpnService>
) {
    WIREGUARD(
        "WireGuard",
        "org.potok.vpn:potokAwgService",
        AwgService::class.java
    ) {
        override fun createProtocol(): Protocol = Wireguard()
    },

    AWG(
        "AmneziaWG",
        "org.potok.vpn:potokAwgService",
        AwgService::class.java
    ) {
        override fun createProtocol(): Protocol = Awg()
    },

    OPENVPN(
        "OpenVPN",
        "org.potok.vpn:potokOpenVpnService",
        OpenVpnService::class.java
    ) {
        override fun createProtocol(): Protocol = OpenVpn()
    },

    CLOAK(
        "Cloak",
        "org.potok.vpn:potokOpenVpnService",
        OpenVpnService::class.java
    ) {
        override fun createProtocol(): Protocol = Cloak()
    },

    XRAY(
        "XRay",
        "org.potok.vpn:potokXrayService",
        XrayService::class.java
    ) {
        override fun createProtocol(): Protocol = Xray()
    };

    private var _protocol: Protocol? = null
    val protocol: Protocol
        get() {
            if (_protocol == null) _protocol = createProtocol()
            return _protocol ?: throw AssertionError("Set to null by another thread")
        }

    protected abstract fun createProtocol(): Protocol

    companion object {
        fun get(protocolName: String): VpnProto = VpnProto.valueOf(protocolName.uppercase())
    }
}