module CipherStash
  module Protect
    module Analysis
      module TokenFilters
        class Base
          def initialize(opts = {})
            @opts = opts
          end
        end

        class Downcase < Base
          def perform(str_or_array)
            Array(str_or_array).map(&:downcase)
          end
        end

        class NGram < Base
          def perform(str_or_array)
            token_length = @opts[:token_length]
            Array(str_or_array).flat_map do |token|
              [].tap do |out|
                (token.length - token_length + 1).times do |i|
                  out << token[i, token_length]
                end

                a, b, c, *rest = token.split("")
                init_ngram = [[a, b, c].join]

                edge_ngram =
                  rest.reduce(init_ngram) do |acc, char|
                  acc.push(acc.last + char)
                end

                out.concat(edge_ngram)
              end
            end
          end
        end
      end
    end
  end
end
