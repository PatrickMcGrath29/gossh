module SshHelper
  class Path
    attr_accessor :alias, :path

    def initialize(hash)
      self.path = hash[:path]
      self.alias = hash[:alias]
    end

    def invalid?
      self.alias.nil? || self.path.nil?
    end

    def to_hash
      {
        path: self.path,
        alias: self.alias
      }
    end
  end
end
