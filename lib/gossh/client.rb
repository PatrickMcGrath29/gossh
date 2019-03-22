require "gossh/connection"
require "fileutils"
require "json"

module GoSSH
  class Client

    # Persistence layer file location for saving SSH paths
    CONFIG_PATH = File.expand_path("~/.gossh/paths.json")

    def initialize
      verify_config
      @connections = fetch_connections&.reject {|connection| connection.invalid? } || []
    end

    # List SSH paths
    def list
      @connections
    end

    def add(obj)
      new_connection = GoSSH::Connection.new(obj)
      if @connections.any? {|connection| connection.alias == new_connection.alias}
        raise GoSSH::Error.new("Error: A connection already exists with this alias")
      else
        @connections << new_connection
        save
      end
    end

    private

    # Save SSH paths to the persistence layer
    def save
      File.open(CONFIG_PATH, "w") do |file|
        file_contents = {
          "connections": @connections.map {|connection| connection.to_hash }
        }
        file.write(file_contents.to_json)
      end
    end

    # Return all saved SSH paths
    def fetch_connections
      return nil unless File.exist?(CONFIG_PATH)

      json_connections = File.read(CONFIG_PATH)
      JSON.parse(json_connections)["connections"].map do |connection|
        conneciton = conneciton.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
        GoSSH::Connection.new(conneciton)
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
