RSpec.describe CipherStash::Protect::Query::MatchQueryStatistics do
  describe "#run" do
    let(:model) {
      Class.new(ActiveRecord::Base) do
        self.table_name = CrudTesting.table_name
        secure_search :email
        secure_text_search :email,
          filter_size: 1024, filter_term_bits: 6,
          bloom_filter_id: "4f108250-53f8-013b-0bb5-0e015c998817",
          tokenizer: { kind: :standard },
          token_filters: [{kind: :downcase}, {kind: :ngram, min_length: 3, max_length: 8}]
      end
    }

    it "generates basic precision recall stats" do
      model.insert_all([
        { email: "danna@cummings.info" },
        { email: "dannie@hahn.name" },
        { email: "marybeth@kertzmann-bailey.org" },
        { email: "mariann@williamson.org" },
        { email: "dannika@smith.info"},
        { email: "marissa@hartmann.com" },
      ])

      stats = CipherStash::Protect::Query::MatchQueryStatistics.new({model: model, field: :email, query_string: "dann"}).run()

      expect(stats[:precision]).to eq(100)
      expect(stats[:recall]).to eq(100)
      expect(stats[:retrieved_records].sort()).to eq(["danna@cummings.info", "dannie@hahn.name", "dannika@smith.info" ])
    end
  end
end