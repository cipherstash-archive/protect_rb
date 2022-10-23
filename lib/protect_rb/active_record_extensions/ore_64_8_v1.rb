require "base64"
module ProtectRB
  module ActiveRecordExtensions
    class ORE_64_8_V1_Type < ::ActiveRecord::Type::Value
      def type
        :ore_64_8_v1
      end

      def cast(value)
        if !value.nil?
          ORE_64_8_V1.encrypt(value)
        else
          # TODO this reveals that the column is set to NULL
          nil
        end
      end

      def deserialize(value)
        if !value.nil?
          ORE_64_8_V1.new([value[1..-2]].pack("h*").unpack("C*"))
        else
          nil
        end
      end

      def serialize(value)
        if !value.nil?
          bytes = value.ciphertext.to_s.bytes

          "(\"\\\\x#{bytes.pack("C*").unpack("h*").first}\")"
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
        new(ore.encrypt(term))
      end

      def initialize(ciphertext)
        @ciphertext = ciphertext
      end

      private

      def self.ore
        cs_protect_key = ENV["CS_PROTECT_KEY"]
        prf_key, prp_key = get_keys(cs_protect_key)

        @ore ||= begin
          ORE::AES128.new([prf_key].pack("H*"), [prp_key].pack("H*"), 64, 8)
        end
      end

      def self.get_keys(protect_key)
        if protect_key.nil? || protect_key[/\H/] || protect_key.length != 64
          raise ProtectRB::Error, "Invalid CS_PROTECT_KEY. Use ProtectRB.generate_key to create a key."
        end

        protect_key.chars.each_slice(32).map(&:join)
      end
    end
  end
end
