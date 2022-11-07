RSpec.describe Protect::Model::DSL do
  describe "class_methods" do
    context "secure_search" do
      it "raises an error when there are no lockbox attributes specified" do
        expect {
          WithoutLockboxAttributes.secure_search :unencrypted_data
        }.to raise_error(Protect::Error, "Attribute 'unencrypted_data' is not encrypted by Lockbox.")
      end

      it "raises an error when the source attribute is not encrypted by Lockbox" do
        expect {
          DslTesting.secure_search :unencrypted_data
        }.to raise_error(Protect::Error,  "Attribute 'unencrypted_data' is not encrypted by Lockbox.")
      end

      it "raises an error when a secure_search attribute is not of type :ore_64_8_v1" do
        expect {
          DslTesting.secure_search :email
        }.to raise_error(Protect::Error,  "Column name 'email_secure_search' is not of type :ore_64_8_v1 (in `secure_search :email`)")
      end

      it "raises an error when secure_search has already been specified for an attribute" do
        expect {
          DslTesting.secure_search :dob
        }.to raise_error(Protect::Error, "Attribute 'dob' is already specified as a secure search attribute.")
      end

      it "allows for secure_search to be specified on an attribute" do
        expect {
          DslTesting.secure_search :full_name
        }.to_not raise_error
      end
    end
  end
end
