##
# Dock0 provides an interface for building Arch images
module Dock0
  class << self
    ##
    # Insert a helper .new() method for creating a new Dock0 object

    def new(*args)
      Dock0::Image.new(*args)
    end
  end
end

require 'dock0/image'
