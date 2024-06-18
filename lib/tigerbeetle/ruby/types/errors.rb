class TigerBeetleError < StandardError; end

class UnexpectedError < TigerBeetleError; end

class OutOfMemoryError < TigerBeetleError; end

class InvalidAddressError < TigerBeetleError; end

class AddressLimitExceededError < TigerBeetleError; end

class InvalidConcurrencyMaxError < TigerBeetleError; end

class SystemResourcesError < TigerBeetleError; end

class NetworkSubsystemError < TigerBeetleError; end

class EmptyBatchError < TigerBeetleError; end

class ClientClosedError < TigerBeetleError; end

class ConcurrencyExceededError < TigerBeetleError; end

class MaximumBatchSizeExceededError < TigerBeetleError; end

class InvalidOperationError < TigerBeetleError; end