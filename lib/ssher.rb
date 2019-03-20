require "ssher/version"
require "ssher/client"
require "thor"
require "cli/ui"

module Ssher
  class Error < StandardError
    attr_accessor :message
    def initialize(message)
      self.message = message
    end
  end

  class CLI < Thor

    desc "ls", "List SSH paths"
    def ls
      paths = Ssher::Client.new.list
      if paths.empty?
        puts "You don't have any paths saved."
      else
        paths.each_with_index do |path, idx|
          puts "#{idx}: #{path.to_s}"
        end
      end
    end

    desc "add ALIAS PATH", "Add a new SSH path, with alias and PATH"
    def add(ssh_alias, ssh_path)
      path_obj = {
        path: ssh_path,
        alias: ssh_alias
      }

      Ssher::Client.new.add(path_obj)
    rescue Error => e
      puts e.message
    end

    desc "goto INDEX", "Connect to a specific SSH server"
    def goto(index)
      index = index.to_i
      paths = Ssher::Client.new.list

      if paths.empty?
        puts "No SSH connections configured"
      elsif paths.length < index
        puts "Invalid index"
      else
        puts "Connecting..."
        exec("ssh " + paths[index].path)
      end
    end

    desc "go", "List SSH connections, then connect to one"
    def go
      paths = Ssher::Client.new.list

      if not paths.empty?
        ::CLI::UI::Prompt.ask("Select an SSH connection") do |handler|
          paths.each_with_index do |path, idx|
            handler.option("#{path.to_s}")  { |selection| exec("ssh " + path.path) }
          end
        end
      else
        puts "No SSH connections configured"
      end
    rescue Interrupt, SystemExit
    end
  end
end
