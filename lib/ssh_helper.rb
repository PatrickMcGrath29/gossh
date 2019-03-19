require "ssh_helper/version"
require "thor"

module SshHelper
  class Error < StandardError; end

  class CLI < Thor

    desc "ls", "List SSH paths"
    def ls
      puts "path 1:"
    end
  end
end
