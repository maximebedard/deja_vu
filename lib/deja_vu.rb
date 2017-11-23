require "json"
require "securerandom"
require "rack/request"
require "deja_vu/expectation"
require "deja_vu/proxy"
require "deja_vu/request_serializer"
require "deja_vu/app"
require "deja_vu/version"

module DejaVu
  def self.root
    File.dirname(__dir__)
  end

  def self.boot
    File.join(root, "bin", "config.ru")
  end
end
