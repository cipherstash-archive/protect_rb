require "hkdf"
require "openssl"
require_relative "./bloom_filter_validations"

module CipherStash
  module Protect
    module ActiveRecordExtensions
      # A bloom filter implementation designed to be used with *secure_text_search fields
      class BloomFilter
        # The min and max values for k and m:

        # K_MIN = 3
        # K_MAX = 16
        # M_MIN = 32
        # M_MAX = 65536

        # The "set" bits of the bloom filter
        attr_reader :bits

        # The size of the bloom filter in bits. Same as "filter_size" in the schema mapping and public docs.
        #
        # Since we only keep track of the set bits, the filter size determines the maximum value of the positions stored in the bits attr.
        # Bit positions are zero-indexed and will have values >= 0 and <= m-1.
        #
        # Valid values are powers of 2 from 32 to 65536.
        #
        # @return [Integer]
        attr_reader :m

        # The number of hash functions applied to each term. Same as "filter_term_bits" in the schema mapping and public docs.
        #
        # Implemented as k slices of a single hash.
        #
        # Valid values are integers from 3 to 16.
        #
        # @return [Integer]
        attr_reader :k

        # Postgres does not support unsigned ints. The max signed small int
        # value is 32767.
        #
        # To be able to store values up to 2 ^ 16 (65536) we need to offset each
        # bit position by -32_768 when storing and querying bloom filters.
        # @return [Integer]
        attr_reader :postgres_offset

        # Creates a new bloom filter with the given key and filter match index settings.
        #
        # @param id [String] the id that is used with the local key to derive a key for hashing. Should be provided as a uuid.
        #
        # @param opts [Hash] the index settings.
        #   "filter_size" and "filter_term_bits" are used to set the m and k attrs respectively.
        #
        # ## Example
        #
        # BloomFilter.new(id, {filter_size: 256, filter_term_bits: 3})
        #
        # @raise [CipherStash::Protect::Error] if opts not provided, or invalid filter_size or filter_term_bits.
        def initialize(id, opts = {})
          unless opts.size > 1 && BloomFilterValidations.valid_filter_options?(opts)
            raise CipherStash::Protect::Error, "Invalid options provided. Expected filter_size and filter_term_bits."
          end

          rails_credentials_key = nil

          if defined?(Rails.application.credentials)
            rails_credentials_key = Rails.application.credentials.try(:protect).try(:fetch, :cs_protect_key, nil)
          end

          key = rails_credentials_key || ENV["CS_PROTECT_KEY"]

          unless hex_string?(key)
            raise CipherStash::Protect::Error, "Invalid CS_PROTECT_KEY. Use rake protect:generate_keys to create a key, (got #{key.inspect})"
          end

          unless valid_uuid?(id)
            raise CipherStash::Protect::Error, "expected id key to be a valid uuid (got #{id.inspect})"
          end

          unless key.length == 64
            raise CipherStash::Protect::Error, "Expected CS_PROTECT_KEY key to have length=64, got length=#{key.length}. Use rake protect:generate_keys to create a key."
          end

          derived_key = HKDF.new(key, :info => id)

          @key = derived_key.read(32)

          @bits = Set.new()

          @postgres_offset = 32768

          @m = opts.fetch(:filter_size)

          unless BloomFilterValidations.valid_m?(@m)
            raise CipherStash::Protect::Error, "filter_size must be a power of 2 between 32 and 65536 (got #{@m.inspect})"
          end

          @k = opts.fetch(:filter_term_bits)

          unless BloomFilterValidations.valid_k?(@k)
            raise CipherStash::Protect::Error, "filter_term_bits must be an integer between 3 and 16 (got #{@k.inspect})"
          end
        end

        # Adds the given terms to the bloom filter and returns the filter instance.
        #
        # @param terms [Array<String> | String] either a list of terms or a single term to add.
        #
        # @return [CipherStash::Protect::ActiveRecordExtensions::BloomFilter]
        def add(terms)
          Array(terms).each { |term| add_single_term(term) }
          self
        end

        # Returns true if the bloom filter is a subset of the other bloom filter and returns false otherwise.
        #
        # @param other [CipherStash::Protect::ActiveRecordExtensions::BloomFilter] the other bloom filter to check against.
        #
        # @return [Boolean]
        def subset?(other)
          @bits.subset?(other.bits)
        end

        # Returns the "set" bits of the bloom filter as an array.
        #
        # @return [CipherStash::Protect::ActiveRecordExtensions::BloomFilter]
        def to_a
          @bits.to_a
        end

        # Returns the bits offset by the @bloom_filter_offset value as an array
        #
        # @return [CipherStash::Protect::ActiveRecordExtensions::BloomFilter]
        def postgres_bits_from_native_bits
          @bits.map do |b|
            b - @postgres_offset
          end
        end

        private

        def add_single_term(term)
          hash = OpenSSL::HMAC.digest("SHA256", @key, term)

          (0..@k-1).map do |slice_index|
            byte_slice = two_byte_slice(hash, slice_index)
            bit_position = little_endian_uint16_from_byte_slice(byte_slice) % @m
            @bits.add(bit_position)
          end
        end

        def two_byte_slice(bytes, index)
          bytes[2*index..2*index+1]
        end

        def little_endian_uint16_from_byte_slice(byte_slice)
          byte_slice.unpack("S<").first
        end

        def hex_string?(val)
          val.instance_of?(String) and /\A\h*\z/.match?(val) && val.length > 0
        end

        def valid_uuid?(id)
          UUID.validate(id)
        end
      end
    end
  end
end
