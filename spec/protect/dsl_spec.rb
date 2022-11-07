RSpec.describe Protect::Model::DSL do
  describe "class_methods" do
    context "secure_search" do
      let(:model) {
        Class.new(ActiveRecord::Base) do
          self.table_name = DslTesting.table_name

          secure_search :dob, type: :date
        end
      }

      it "raises an error when a secure_search attribute is not of type :ore_64_8_v1" do
        expect {
          model.secure_search :email
        }.to raise_error(Protect::Error,  "Column name 'email_secure_search' is not of type :ore_64_8_v1 (in `secure_search :email`)")
      end

      it "raises an error when secure_search has already been specified for an attribute" do
        expect {
          model.secure_search :dob
        }.to raise_error(Protect::Error, "Attribute 'dob' is already specified as a secure search attribute.")
      end

      it "allows for secure_search to be specified on an attribute" do
        expect {
          model.secure_search :full_name
        }.to_not raise_error
      end
    end
  end
end
