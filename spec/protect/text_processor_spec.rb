require 'cipherstash/protect/analysis/text_processor'

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

  describe "Standard text processor with ngram filter" do
    it "splits text into ngrams using token length of 3" do
      tokenizer =
        CipherStash::Protect::Analysis::TextProcessor.new({
          token_filters:[
            {kind: :downcase},
            {kind: :ngram, token_length: 3}
          ],
          tokenizer: { kind: :standard }
        })
      result = tokenizer.perform("This is an example of an ngram filter")
      expect(result).to eq(["thi", "his", "exa", "xam", "amp", "mpl", "ple", "ngr", "gra", "ram", "fil", "ilt", "lte", "ter"])
    end

    it "raises an error if a token length is not provided" do
      expect {
        CipherStash::Protect::Analysis::TextProcessor.new({
          token_filters:[
            {kind: :downcase},
            {kind: :ngram}
          ],
          tokenizer: { kind: :standard }
        })
      }.to raise_error(CipherStash::Protect::Error, "Token length not provided. Please specify token length using '{kind: :ngram, tokenLength: 3}'")
    end
  end
end
