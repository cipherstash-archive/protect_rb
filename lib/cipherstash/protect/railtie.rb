module Protect
  class Railtie < Rails::Railtie
    rake_tasks do
      path = File.expand_path(File.join(__dir__, "../tasks/protect.rake"))
      load path
    end
  end
end
