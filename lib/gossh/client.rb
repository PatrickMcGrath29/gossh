require "gossh/path"
require "fileutils"
require "json"

module GoSSH
  class Client

    # Persistence layer file location for saving SSH paths
    CONFIG_PATH = File.expand_path("~/.gossh/paths.json")

    def initialize
      verify_config
      @paths = fetch_paths&.reject {|path| path.invalid? } || []
    end

    # List SSH paths
    def list
      @paths
    end

    def add(obj)
      new_path = GoSSH::Connection.new(obj)
      if @paths.any? {|path| path.alias == new_path.alias}
        raise GoSSH::Error.new("Error: A path already exists with this alias")
      else
        @paths << new_path
        save
      end
    end

    private

    # Save SSH paths to the persistence layer
    def save
      File.open(CONFIG_PATH, "w") do |file|
        file_contents = {
          "paths": @paths.map {|path| path.to_hash }
        }
        file.write(file_contents.to_json)
      end
    end

    # Return all saved SSH paths
    def fetch_paths
      return nil unless File.exist?(CONFIG_PATH)

      json_paths = File.read(CONFIG_PATH)
      JSON.parse(json_paths)["paths"].map do |path|
        path = path.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
        GoSSH::Path.new(path)
      end
    end

    # Check if the '~/.gossh' directory exists, and create it if it doesn't
    def verify_config
      dirname = File.dirname(CONFIG_PATH)

      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end
    end
  end
end
