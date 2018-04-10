module X32Show

  class Snippet

    attr_reader :name

    def initialize(name, mutes)
      @name, @mutes = name, mutes
    end

    def header
      %Q{%s "#{name}" 128 -1 0 0 1} % [Version]
    end

    def output
      [header.ljust(127)] + @mutes.map.with_index do |mute, i|
        %q{/ch/%02d/mix/on %s} % [i+1, mute ? 'ON' : 'OFF']
      end
    end

    def show_line(counter)
      %q{snippet/%03d "%s" 128 -1 0 0 1} % [counter, name]
    end

  end

end
