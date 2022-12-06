RSpec.describe CipherStash::Protect::Model do
  describe "class methods" do
    context "with no protected attributes" do
      let(:model) {
        Class.new(ActiveRecord::Base) do
          self.table_name = nil
        end
      }

      it "detects that no attributes are being protected" do
        expect(model.protect_search_attrs).to eql({})
        expect(model.is_protected?).to be false
      end
    end

    context "with some protected attributes" do
      let(:model) { DslTesting }

      it "detects that no attributes are being protected" do
        expect(model.protect_search_attrs.keys).to eql([:dob])
        expect(model.is_protected?).to be true
      end
    end
  end
end
