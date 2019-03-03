module X32Show

  class Channel

    attr_reader :num, :name, :icon, :colour

    def initialize(num, name, icon=Icon.default, colour=nil)
      colour = icon.default_colour unless colour
      @num, @name, @icon, @colour = num, name, icon, Colour[colour]
    end

    def output
      %q{/ch/%02d/config "%s" %d %s %d} % [num, name.gsub(/\s+/, ' ')[0..11].strip, icon.code, colour.code, visible ? 1 : 0]
    end

    def visible
      #show name on channel strip
      true
    end

    def as_json
      {num: num, name: name, icon: icon.as_json, colour: colour.as_json}
    end

  end

end
