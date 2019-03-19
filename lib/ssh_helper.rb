require "ssh_helper/version"
require "ssh_helper/client"
require "thor"

module SshHelper
  class Error < StandardError
    attr_accessor :message
    def initialize(message)
      self.message = message
    end
  end

  class CLI < Thor

    desc "ls", "List SSH paths"
    def ls
      paths = SshHelper::Client.new.list
      if paths.empty?
        puts "You don't have any paths saved."
      else
        paths.each_with_index do |path, idx|
          puts "#{idx}: #{path.alias} - #{path.path}"
        end
      end
    end

    desc "add ALIAS PATH", "Add a new SSH path, with alias and PATH"
    def add(ssh_alias, ssh_path)
      path_obj = {
        path: ssh_path,
        alias: ssh_alias
      }

      SshHelper::Client.new.add(path_obj)
    rescue Error => e
      puts e.message
    end
  end
end
