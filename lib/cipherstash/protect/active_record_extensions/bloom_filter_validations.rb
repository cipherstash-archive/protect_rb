module CipherStash
  module Protect
    module ActiveRecordExtensions
      module BloomFilterValidations
        M_MIN = 32
        M_MAX = 65536
        K_MIN = 3
        K_MAX = 16

        def self.power_of_2?(m)
          Math.log2(m).floor == Math.log2(m)
        end

        def self.valid_m?(m)
          m.instance_of?(Integer) && M_MIN <= m && m <= M_MAX && power_of_2?(m)
        end

        def self.valid_k?(k)
          k.instance_of?(Integer) && (K_MIN..K_MAX).to_a.include?(k)
        end

        def self.valid_filter_options?(opts)
          opts.has_key?(:filter_size) && opts.has_key?(:filter_term_bits)
        end
      end
    end
  end
end
