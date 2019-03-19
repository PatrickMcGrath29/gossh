module SshHelper
  class Version
    # Major version: Increment on major API change
    MAJOR = "0"
    # Minor version: Increment with new backwards-compatible functionality
    MINOR = "1"
    # Patch version: Increment on bugfix
    PATCH = "0"

    VERSION = [MAJOR, MINOR, PATCH].join(".").freeze

    def self.gem_version
      Gem::Version.new(to_s)
    end

    def to_s
      VERSION
    end
  end

  VERSION = Version::VERSION
end
