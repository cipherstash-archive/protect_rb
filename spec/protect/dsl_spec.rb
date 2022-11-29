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

      context "when a secure_search attribute does not exist" do
        it "raises an error if there are no pending migrations" do
          expect {
            Class.new(ActiveRecord::Base) do
              self.table_name = DslTesting.table_name
              secure_search :unicorn, type: :string
            end
          }.to raise_error(Protect::Error, "Column name 'unicorn_secure_search' does not exist")
        end

        it "silently logs if there are pending migrations" do
          allow_any_instance_of(ActiveRecord::MigrationContext).to(
            receive(:needs_migration?).and_return(true)
          )

          logger = Logger.new(IO::NULL)
          expect(logger).to receive(:debug).with(/Protect cannot find column 'unicorn_secure_search' on '[^']+'/)
          ActiveRecord::Base.logger = logger

          Class.new(ActiveRecord::Base) do
            self.table_name = DslTesting.table_name
            secure_search :unicorn, type: :string
          end
        end
      end
    end
  end
end
