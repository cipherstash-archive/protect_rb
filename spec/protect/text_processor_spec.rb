RSpec.describe CipherStash::Protect::Analysis::TextProcessor do
  describe "Standard text processor" do
    it "splits text based on word boundaries" do
      tokenizer =
        CipherStash::Protect::Analysis::TextProcessor.new({
          token_filters:[
            { kind: :downcase }
          ],
         tokenizer: { kind: :standard }
        })
      result = tokenizer.perform("This is an example of a standard tokenizer")
      expect(result.length).to eq(8)
      expect(result).to eq(["this", "is", "an", "example", "of", "a", "standard", "tokenizer"])
    end

    it "raises an error if a tokenizer is not passed to the text processor" do
      expect {
        CipherStash::Protect::Analysis::TextProcessor.new({
          token_filters:[
            { kind: :downcase }
          ]
        })
      }.to raise_error(CipherStash::Protect::Error, "No tokenizer provided. Use tokenizer: {kind: :standard} in your settings.")
    end

    it "raises an error if a tokenizer other than standard is provided" do
      expect {
        CipherStash::Protect::Analysis::TextProcessor.new({
          token_filters:[
            { kind: :downcase }
          ],
          tokenizer: { kind: "non-standard" }
        })
      }.to raise_error(CipherStash::Protect::Error, "Unknown tokenizer: 'non-standard'. Use tokenizer: {kind: :standard} in your settings.")
    end

    it "raises an error if no token filters are provided" do
      expect {
        CipherStash::Protect::Analysis::TextProcessor.new({
          tokenizer: { kind: :standard }
        })
      }.to raise_error(CipherStash::Protect::Error, "No token filters provided.")
    end
  end

  describe "Standard text processor with ngram and edge_ngram filter" do
    it "raises an error if min length and max length are not provided" do
      expect {
        CipherStash::Protect::Analysis::TextProcessor.new({
          token_filters:[
            {kind: :downcase},
            {kind: :ngram}
          ],
          tokenizer: { kind: :standard }
        })
      }.to raise_error(CipherStash::Protect::Error, "Min length and max length not provided with ngram filter. Please specify ngram token length using '{kind: :ngram, min_length: 3, max_length: 8}'")
    end

    ["1", { foo: "bar" }, Object.new].each do |length|
      it "raises an error if invalid length of #{length.inspect} provided" do
        expect {
          CipherStash::Protect::Analysis::TextProcessor.new({
            token_filters:[
              {kind: :downcase},
              {kind: :ngram, min_length: length, max_length: length}
            ],
            tokenizer: { kind: :standard }
          })
        }.to raise_error(CipherStash::Protect::Error, "The values provided to the min and max length must be of type Integer.")
      end
    end

    it "raises an error if the min length is greater than the max length" do
      expect {
          CipherStash::Protect::Analysis::TextProcessor.new({
            token_filters:[
              {kind: :downcase},
              {kind: :ngram, min_length: 6, max_length: 5}
            ],
            tokenizer: { kind: :standard }
          })
        }.to raise_error(CipherStash::Protect::Error, "The ngram filter min length must be less than or equal to the max length")
    end

    it "splits text into ngrams using min length of 3 and max length of 8" do
      tokenizer =
        CipherStash::Protect::Analysis::TextProcessor.new({
          token_filters:[
            {kind: :downcase},
            {kind: :ngram, min_length: 3, max_length: 8}
          ],
          tokenizer: { kind: :standard }
        })
      result = tokenizer.perform("Example")
      expect(result).to eq(["exa", "xam", "amp", "mpl", "ple", "exam", "xamp", "ampl", "mple", "examp", "xampl", "ample", "exampl", "xample", "example"])
    end

    it "returns ngrams including whole token if token length > max token length" do
      tokenizer =
        CipherStash::Protect::Analysis::TextProcessor.new({
          token_filters:[
            {kind: :downcase},
            {kind: :ngram, min_length: 3, max_length: 8}
          ],
          tokenizer: { kind: :standard }
        })
      result = tokenizer.perform("Connection")
      expect(result).to eq(
        [
          "con",
          "onn",
          "nne",
          "nec",
          "ect",
          "cti",
          "tio",
          "ion",
          "conn",
          "onne",
          "nnec",
          "nect",
          "ecti",
          "ctio",
          "tion",
          "conne",
          "onnec",
          "nnect",
          "necti",
          "ectio",
          "ction",
          "connec",
          "onnect",
          "nnecti",
          "nectio",
          "ection",
          "connect",
          "onnecti",
          "nnectio",
          "nection",
          "connecti",
          "onnectio",
          "nnection",
          "connection"
        ]
      )
    end
  end
end
