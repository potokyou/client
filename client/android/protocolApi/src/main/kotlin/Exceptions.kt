package org.potok.vpn.protocol

sealed class ProtocolException(message: String? = null, cause: Throwable? = null) : Exception(message, cause)

class LoadLibraryException(message: String? = null, cause: Throwable? = null) : ProtocolException(message, cause)
class BadConfigException(message: String? = null, cause: Throwable? = null) : ProtocolException(message, cause)

class VpnStartException(message: String? = null, cause: Throwable? = null) : ProtocolException(message, cause)
class VpnException(message: String? = null, cause: Throwable? = null) : ProtocolException(message, cause)
