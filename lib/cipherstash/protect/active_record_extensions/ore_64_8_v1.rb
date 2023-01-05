require 'ore-rs'

module CipherStash
  module Protect
    module ActiveRecordExtensions
      class ORE_64_8_V1_Type < ::ActiveRecord::Type::Value
        def type
          :ore_64_8_v1
        end

        def cast(value)
          # binding.pry
          if !value.nil?
            ORE_64_8_V1.encrypt(value)
          else
            # TODO this reveals that the column is set to NULL
            nil
          end
        end

        def deserialize(value)
          if !value.nil?
            ORE_64_8_V1.new([value[1..-2]].pack("H*").unpack("C*"))
          else
            nil
          end
        end

        def serialize(value)
          # binding.pry
          if !value.nil?
            # value will be an array of
            # bytes = value.ciphertext.to_s.bytes
            terms =
              value.map do |v|
                binding.pry
              bytes = v.ciphertext.to_s.bytes
              "(\"\\\\x#{bytes.pack("C*").unpack("H*").first}\")"
            end
            # binding.pry
            "{#{terms.join(",")}}"
          else
            nil
          end
        end
      end


      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Type.register("ore_64_8_v1", ORE_64_8_V1_Type, override: true, adapter: :postgresql)
      end

      class ORE_64_8_V1
        attr_reader :ciphertext

        def self.encrypt(term)
          if term.nil?
            nil
          else
            terms =
              if term.instance_of?(String)
                orderise_string(term)
              else
                [term]
              end
            binding.pry
            terms.map { |t| new(ore.encrypt(t)) }
          end
        end

        def initialize(ciphertext)
          @ciphertext = ciphertext
        end

        private

        def self.ore
          rails_credentials_key = nil

          if defined?(Rails.application.credentials)
            rails_credentials_key = Rails.application.credentials.try(:protect).try(:fetch, :cs_protect_key, nil)
          end

          cs_protect_key = rails_credentials_key || ENV["CS_PROTECT_KEY"]

          prf_key, prp_key = get_keys(cs_protect_key)

          @ore ||= begin
            ORE::AES128.new([prf_key].pack("H*"), [prp_key].pack("H*"), 64, 8)
          end
        end

        def self.get_keys(protect_key)
          if protect_key.nil? || protect_key[/\H/] || protect_key.length != 64
            raise CipherStash::Protect::Error, "Invalid CS_PROTECT_KEY. Use rake protect:generate_keys to create a key."
          end

          protect_key.chars.each_slice(32).map(&:join)
        end

        # NOTE: This is a copy of the implementation from the Ruby Client.
        #
        # The comments on this method are really comprehensive,
        # and pretty awesome, so they are a direct copy/paste from the original method.
        #
        # https://github.com/cipherstash/ruby-client/blob/main/lib/cipherstash/index/range.rb#L75
        def self.orderise_string(s)
          unless s.clone.force_encoding("US-ASCII").valid_encoding?
              raise Client::Error::InvalidRecordError, "Can only order strings that are pure ASCII"
          end

          # This all very much relies on ASCII character numbering.  A copy of `ascii`(7)
          # up on a convenient terminal may assist in understanding what's going
          # on here.

          # First up, let's transmogrify the string we were given into one that only contains
          # a controlled subset of characters, that we can easily map into a smaller numeric
          # space.
          s = s
            # We care not for your capitals!
            .downcase
            # Any group of rando characters sort at the end
            .gsub(/[^a-z0-9[:space:]]+/, '~')
            # Any amount of whitespace comes immediately after letters
            .gsub(/[[:space:]]+/, '{')
            # Numbers come after spaces
            .gsub(/[0-9]/, '|')

          # Next, we turn that string of characters into a "packed" number that represents the
          # whole string, but in a more compact form than would be used if each character took
          # up the full seven or eight bits used by regular ASCII.
          n = s
            .each_char
            # 'a' => 1, 'b' => 2, ..., 'z' => 27, '{' => 28, '|' => 29,
            # '}' => 30 (unused), '~' => 31.  0 is kept as "no character" so
            # that short strings sort before longer ones.
            .map { |c| c.ord - 96 }
            # Turn the whole thing into one giant number, with each character
            # occupying five bits of said number.
            .inject(0) { |i, c| (i << 5) + c }

          # Thirdly, we need to turn the number into one whose in-memory representation
          # has a length in bits that is a multiple of 64.  This is to ensure that
          # the first character has the most-significant bits possible, so it
          # sorts the highest.
          n = n << (64 - (s.length * 5) % 64)

          # And now, semi-finally, we can turn all that gigantic mess into an array of terms
          [].tap do |terms|
            while n > 0
              terms.unshift(n % 2**64)
              n >>= 64
            end
          # Only six ORE ciphertexts can fit into the database
          end[0, 6]
        end
      end
    end
  end
end
