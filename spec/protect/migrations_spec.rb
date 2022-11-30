RSpec.describe "A Protect customer can run migrations to define searchable columns", :type => :extensions_test do
  let(:migration) {
    class AcmeCorpUser < ActiveRecord::Migration[RAILS_VERSION]
      def change
        create_table :acme_corp_users do |t|
          t.column :email_secure_search, :ore_64_8_v1
        end
      end
    end
    AcmeCorpUser
  }

  describe "when the custom extensions are installed" do
    before(:each) do
      Protect::DatabaseExtensions.install rescue nil
    end

    after(:each) do
      Protect::DatabaseExtensions.uninstall rescue nil
      migration.migrate(:down) rescue nil
    end

    it "should be possible to write a migration to create a column of type ore_64_8_v1" do
      expect { migration.migrate(:up) }.to_not raise_error
    end
  end

  describe "when the custom extensions are not installed" do
    after(:each) do
      migration.migrate(:down) rescue nil
    end

    it "should be not possible to write a migration to create a column of type ore_64_8_v1" do
      expect { migration.migrate(:up) }.to raise_error(ActiveRecord::StatementInvalid)
    end
  end
end
