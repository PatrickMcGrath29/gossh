require "ssh_helper/path"
require "fileutils"
require "json"

module SshHelper
  class Client

    # Persistence location for saving SSH paths
    CONFIG_PATH = File.expand_path("~/.ssh_helper/paths.json")

    def initialize
      verify_config
      @paths = fetch_paths.reject {|path| path.invalid? }
    end

    # List SSH paths
    def list
      @paths
    end

    private

    # Return all saved SSH paths
    def fetch_paths
      return nil unless File.exist?(CONFIG_PATH)

      json_paths = File.read(CONFIG_PATH)
      JSON.parse(json_paths)["paths"].map do |path|
        SshHelper::Path.new(path)
      end
    end

    # Check if the '~/.ssh_helper' directory exists, and create it if it doesn't
    def verify_config
      dirname = File.dirname(CONFIG_PATH)

      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end
    end
  end
end
