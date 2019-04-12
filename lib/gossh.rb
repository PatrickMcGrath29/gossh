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
      connections = GoSSH::Client.new.list
      if connections.empty?
        puts "You don't have any connections saved."
      else
        connections.each_with_index do |conn, idx|
          puts "#{idx}: #{conn.to_s}"
        end
      end
    rescue Interrupt, SystemExit
    end


    desc "add", "Add a new SSH connection"
    def add
      ::CLI::UI::Frame.open('New SSH Connection', color: :blue) do
        alias_name = ::CLI::UI.ask("Enter Alias Name")
        ssh_path = ::CLI::UI.ask("Enter SSH Path")
        key_encrpytion = ::CLI::UI.ask("Private Key Encryption?", options: %w{Yes No})
        if key_encrpytion == "Yes"
          key_path = ::CLI::UI.ask("Private Key Path", is_file: true)
        end

        GoSSH::Client.new.add({
          alias: alias_name,
          path: ssh_path
        })
      end
    rescue Interrupt, SystemExit
    end


    desc "goto ALIAS", "Connect to a specific SSH connection"
    def goto(alias_name)
      connections = GoSSH::Client.new.list
      match = connections.select { |conn| conn.alias == alias_name }&.first

      if match.nil?
        puts "No Matching SSH Connection Found"
      else
        puts "Connecting..."
        exec("ssh " + match.path)
        end
      end
    rescue Interrupt, SystemExit
    end


    desc "go", "List SSH connections, then connect to one"
    def go
      connections = GoSSH::Client.new.list

      if not connections.empty?
        ::CLI::UI::Prompt.ask("Select an SSH connection") do |handler|
          connections.each_with_index do |conn, idx|
            handler.option("#{conn.to_s}")  { |selection| exec("ssh " + conn.path) }
          end
        end
      else
        puts "No SSH connections configured"
      end
    rescue Interrupt, SystemExit
    end
  end
end
