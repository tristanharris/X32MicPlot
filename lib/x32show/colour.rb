module X32Show

  class Colour

    attr_reader :name, :code

    def initialize(name, code)
      @name, @code = name, code
    end

    List = {
      black: new('Black', 'OFF'),
      red: new('Red', 'RD'),
      green: new('Green', 'GN'),
      yellow: new('Yellow', 'YE'),
      blue: new('Blue', 'BL'),
      magenta: new('Magenta', 'MG'),
      cyan: new('Cyan', 'CY'),
      white: new('White', 'WH'),
      iblack: new('Inverse Black', 'OFFi'),
      ired: new('Inverse Red', 'RDi'),
      igreen: new('Inverse Green', 'GNi'),
      iyellow: new('Inverse Yellow', 'YEi'),
      iblue: new('Inverse Blue', 'BLi'),
      imagenta: new('Inverse Magenta', 'MGi'),
      icyan: new('Inverse Cyan', 'CYi'),
      iwhite: new('Inverse White', 'WHi'),
    }

    def self.[](id)
      List[id]
    end

    def self.random
      List.values.sample
    end

    def self.default
      List[:black]
    end

    def as_json
      code
    end

  end

end
