module X32Show

  class Scene

    attr_reader :name, :note

    def initialize(name, note, channels)
      @name, @note, @channels = name, note, channels
    end

    def output
      [header.ljust(127)] + @channels.map.with_index do |channel, i|
        channel.output
      end
    end

    def show_line(counter)
      %q{scene/%03d "%s" "%s" %%000000000 1} % [counter, name, note]
    end

    def header
      %q{%s "%s" "%s" %%000000000 1} % [Version, name, note]
    end

  end

end
