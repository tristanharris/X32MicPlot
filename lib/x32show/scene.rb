module X32Show

  class Scene

    attr_reader :id, :name, :note

    def initialize(id, name, note, channels)
      @id, @name, @note, @channels = id, name, note, channels
    end

    def output
      [header.ljust(127)] + @channels.map do |channel|
        channel.output
      end
    end

    def show_line
      %q{scene/%03d "%s" "%s" %%000000000 1} % [id, name, note]
    end

    def header
      %q{%s "%s" "%s" %%000000000 1} % [Version, name, note]
    end

  end

end
