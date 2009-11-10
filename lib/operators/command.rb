module Operators
  class Command
    def self.run(command)
      %x{command}
    end
  end
end