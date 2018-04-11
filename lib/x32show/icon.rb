module X32Show

  class Icon

    attr_reader :name, :code

    def initialize(name, code)
      @name, @code = name, code
    end

    def self.random
      new('image', (1..74).to_a.sample)
    end

    def self.none
      new('', 1)
    end

    def self.default
      new('Man', 41)
    end

    def path
      File.join(File.dirname(File.dirname(File.dirname(__FILE__))), 'icons', code.to_s+'.gif')
    end

  end

end
