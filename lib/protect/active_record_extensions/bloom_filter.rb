require "openssl"
require_relative "./bloom_filter_validations"

module Protect
  module ActiveRecordExtensions
    # A bloom filter implementation designed to be used with *secure_text_search fields
    class BloomFilter
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

      # Creates a new bloom filter with the given key and filter match index settings.
      #
      # @param key [String] the key to use for hashing terms. Should be provided as a hex-encoded string.
      #
      # @param opts [Hash] the index settings.
      #   "filter_size" and "filter_term_bits" are used to set the m and k attrs respectively.
      #
      # @raise [Protect::Error] if opts not provided, or invalid filter_size or filter_term_bits.
      def initialize(key, opts = {})
        unless opts.size > 1 && BloomFilterValidations.valid_filter_options?(opts)
          raise Protect::Error, "Invalid options provided. Expected filter_size and filter_term_bits."
        end

        unless hex_string?(key)
          raise Protect::Error, "expected bloom filter key to be a hex-encoded string (got #{key.inspect})"
        end

        @key = [key].pack("H*")

        unless @key.length == 32
          raise Protect::Error, "expected bloom filter key to have length=32, got length=#{@key.length}"
        end

        @bits = Set.new()

        @m = opts.fetch(:filter_size)

        unless BloomFilterValidations.valid_m?(@m)
          raise Protect::Error, "filter_size must be a power of 2 between 32 and 65536 (got #{@m.inspect})"
        end

        @k = opts.fetch(:filter_term_bits)

        unless BloomFilterValidations.valid_k?(@k)
          raise Protect::Error, "filter_term_bits must be an integer between 3 and 16 (got #{@k.inspect})"
        end
      end

      # Adds the given terms to the bloom filter and returns the filter instance.
      #
      # @param terms [Array<String> | String] either a list of terms or a single term to add.
      #
      # @return [Protect::ActiveRecordExtensions::BloomFilter]
      def add(terms)
        Array(terms).each { |term| add_single_term(term) }
        self
      end

      # Returns true if the bloom filter is a subset of the other bloom filter and returns false otherwise.
      #
      # @param other [Protect::ActiveRecordExtensions::BloomFilter] the other bloom filter to check against.
      #
      # @return [Boolean]
      def subset?(other)
        @bits.subset?(other.bits)
      end

      # Returns the "set" bits of the bloom filter as an array.
      #
      # @return [Protect::ActiveRecordExtensions::BloomFilter]
      def to_a
        @bits.to_a
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
        val.instance_of?(String) and /\A\h*\z/.match?(val)
      end
    end
  end
end
