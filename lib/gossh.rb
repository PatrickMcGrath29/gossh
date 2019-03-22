require "gossh/version"
require "gossh/client"
require "thor"
require "cli/ui"

module GoSSH
  class Error < StandardError
    attr_accessor :message
    def initialize(message)
      self.message = message
    end
  end

  class CLI < Thor

    desc "ls", "List SSH Connections"
    def ls
      paths = GoSSH::Client.new.list
      if paths.empty?
        puts "You don't have any paths saved."
      else
        paths.each_with_index do |path, idx|
          puts "#{idx}: #{path.to_s}"
        end
      end
    rescue Interrupt, SystemExit
    end

    desc "add", "Add a new SSH connection"
    def add
      ::CLI::UI::Frame.open('New SSH Connection', color: :blue) do
        alias_name = ::CLI::UI.ask("Enter Alias Name")
        ssh_connection = ::CLI::UI.ask("Enter SSH Host")
        key_encrpytion = ::CLI::UI.ask("Private Key Encryption?", options: %w{Yes No})
        if key_encrpytion == "Yes"
          key_path = ::CLI::UI.ask("Private Key Path", is_file: true)
        end

      end
    rescue Interrupt, SystemExit
    end

    desc "goto INDEX", "Connect to a specific SSH connection"
    def goto(index)
      index = index.to_i
      paths = GoSSH::Client.new.list

      if paths.empty?
        puts "No SSH connections configured"
      elsif paths.length < index
        puts "Invalid index"
      else
        puts "Connecting..."
        exec("ssh " + paths[index].path)
      end
    rescue Interrupt, SystemExit
    end

    desc "go", "List SSH connections, then connect to one"
    def go
      paths = GoSSH::Client.new.list

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
