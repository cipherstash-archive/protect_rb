module ProtectRB
  module DatabaseExtensions
    def self.install
      ActiveRecord::Base.connection.execute(install_script)
    end

    def self.uninstall
      ActiveRecord::Base.connection.execute(uninstall_script)
    end

    private

    def self.install_script
      File.read(File.join(dirname_for_adapter, "install.sql"))
    end

    def self.uninstall_script
      File.read(File.join(dirname_for_adapter, "uninstall.sql"))
    end

    def self.dirname_for_adapter
      database_kind = ActiveRecord::Base.connection.adapter_name.downcase
      if database_kind =~ /postgresql/
        File.join(__dir__, "database_extensions", "postgresql")
      else
        raise NotImplementedError, "ProtectRB does not (yet) support #{database_kind}"
      end
    end
  end
end