module X32Show

  class Icon

    attr_reader :name, :code, :default_colour

    def initialize(name, code, colour)
      @name, @code, @default_colour = name, code, colour
    end

    List = {
      none: [1, :black],
      male: [41, :blue],
      female: [42, :magenta],
      backing: [43, :white],
      group: [44, :white]
    }.map do |name, info|
      id, colour = *info
      [name, self.new(name, id, colour)]
    end.to_h

    def self.random
      new('image', (1..74).to_a.sample)
    end

    def self.none
      List[:none]
    end

    def self.default
      List[:male]
    end

    def self.[](name)
      name.downcase!.strip!
      name = :none if name.empty? || !List.include?(name.to_sym)
      List[name.to_sym]
    end

    def path
      File.join(File.dirname(File.dirname(File.dirname(__FILE__))), 'icons', code.to_s+'.gif')
    end

  end

end
