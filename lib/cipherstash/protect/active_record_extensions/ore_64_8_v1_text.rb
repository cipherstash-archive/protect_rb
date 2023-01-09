require 'ore-rs'

module CipherStash
  module Protect
    module ActiveRecordExtensions
      class ORE_64_8_V1_Text_Type < ::ActiveRecord::Type::Value
        def type
          :ore_64_8_v1_text
        end

        def cast(value)
          # binding.pry
          if !value.nil?
            ORE_64_8_V1_Text.encrypt(value)
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
            terms =
              value.map do |term|
                bytes = term.ciphertext.to_s.bytes
                # '("\\x1f82fb4c7c674e82a4ade6ecbd
                # '("\\x1f82fb4c7c674e82a4ade6ecbd22e56ab66ae5381b3fc06a3a4e5a597463f40e728ca96983903fd865eef13f8bd24027efdc8d8d70c51f7141bf2a13aa7f842e0d0c71fdf999a97e66e333deaebd8bffe5e745e8319b3786d6f36b9cc4caa7c96bf0a9e34de9f6abf29399da54a87b21735503f0a0d53e62078c0419fb5aab254fd4f701937ecaf9ce679eb2f898a5a019400272fab7a21e36c7e8eb8c058ef8dbabd925849eb3125cb548bfa42bc81036a1609979cd44b1ee6cac19d36db18d40a56777c6369ddd22187bdbf4cd3258837dd402c255438e492b1de620d571ae22400ba8df5917f11efff97cb87f7344ed242a4b51b65a45f7656719d170f942de52352c74953222ff148afd1ed6e8d66302af9e20b68643b63481dd38a40023a281c79a434f4b5d2c4c779ecd02c9890a084aa3858e9d55d36150ec490df6c6e1f2c7df7da89df666a0df86399dcf38a08e4a6c821db2c0eaecdc1fbac45784b3ba527c91884a5bb69e87ec46a68a50e237408964137ce7325f1ebc0f83b48a0169479496825dcb007271519ab0721dc286535bfec01f4e")'


                # "\\x#{bytes.pack("C*").unpack("H*").first}"
                # "\\\\x#{bytes.pack("C*").unpack("H*").first}"
                # "(\\\\x#{bytes.pack("C*").unpack("H*").first})"
                # "E'\\\\x#{bytes.pack("C*").unpack("H*").first}'"
                "(\"\\\\x#{bytes.pack("C*").unpack("H*").first}\")"
                # bytes.pack("C*")
                # binding.pry
              end
              # binding.pry
              # PG::TextEncoder::Array.new.encode(terms)
            # PG::TextEncoder::Record.new.encode(PG::TextEncoder::Array.new.encode(terms))
            # "{'#{terms.join(",")}'}"
            # encoded_terms = PG::TextEncoder::Array.new.encode(terms)
            # "(\"{#{encoded_terms}}\")"
            "(\"{#{terms.join(",")}}\")"

          else
            nil
          end
        end
      end

      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Type.register("ore_64_8_v1_text", ORE_64_8_V1_Text_Type, override: true, adapter: :postgresql)
      end

      class ORE_64_8_V1_Text
        attr_reader :ciphertext

        def self.encrypt(term)
          if term.nil?
            nil
          else
            terms =
              if term.instance_of?(String)
                orderise_string(term)
              else
                term
              end
            # binding.pry
            terms.map { |t| CipherStash::Protect::ActiveRecordExtensions::ORE_64_8_V1.encrypt(t) }
          end
        end

        def initialize(ciphertext)
          @ciphertext = ciphertext
        end

        private

        # NOTE: This is a copy of the implementation from the Ruby Client.
        #
        # The comments on this method are really comprehensive,
        # so they are a direct copy/paste from the original method.
        #
        # https://github.com/cipherstash/ruby-client/blob/main/lib/cipherstash/index/range.rb#L75
        def self.orderise_string(str)
          unless str.clone.force_encoding("US-ASCII").valid_encoding?
              raise Client::Error::InvalidRecordError, "Can only order strings that are pure ASCII"
          end

          # This all very much relies on ASCII character numbering.  A copy of `ascii`(7)
          # up on a convenient terminal may assist in understanding what's going
          # on here.

          # First up, let's transmogrify the string we were given into one that only contains
          # a controlled subset of characters, that we can easily map into a smaller numeric
          # space.
          str = str
            # We care not for your capitals!
            .downcase
            # Any group of rando characters sort at the end
            .gsub(/[^a-z0-9[:space:]]+/, '~')
            # Any amount of whitespace comes immediately after letters
            .gsub(/[[:space:]]+/, '{')
            # Numbers come after spaces
            .gsub(/[0-9]/, '|')

          # eg "marybeth@kertzmann-bailey.org" => "marybeth~kertzmann~bailey~org"

          # Next, we turn that string of characters into a "packed" number that represents the
          # whole string, but in a more compact form than would be used if each character took
          # up the full seven or eight bits used by regular ASCII.
          num = str
            .each_char
            # 'a' => 1, 'b' => 2, ..., 'z' => 27, '{' => 28, '|' => 29,
            # '}' => 30 (unused), '~' => 31.  0 is kept as "no character" so
            # that short strings sort before longer ones.
            # turns each char into a codepoint starting from 1 for a etc.
            #  eg[13,1,18,25,2,5,20,8,30,11,5,18,20,26,13,1,14,14,30,2,1,9,12,5,25,30,15,18,7]
            .map { |c| c.ord - 96 }
            # Turn the whole thing into one giant number, with each character
            # occupying five bits of said number.
            # eg 18188478222059287869564498627200381756587591
            .inject(0) { |i, c| (i << 5) + c }

          # Thirdly, we need to turn the number into one whose in-memory representation
          # has a length in bits that is a multiple of 64.  This is to ensure that
          # the first character has the most-significant bits possible, so it
          # sorts the highest.
          num = num << (64 - (str.length * 5) % 64)

          # And now, semi-finally, we can turn all that gigantic mess into an array of terms
          [].tap do |terms|
            while num > 0
              terms.unshift(num % 2**64)
              num >>= 64
            end
          # Only six ORE ciphertexts can fit into the database
          end[0, 6]
        end
      end
    end
  end
end
