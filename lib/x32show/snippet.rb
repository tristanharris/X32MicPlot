module X32Show

  class Snippet

    attr_reader :id, :name

    def initialize(id, mutes, channels, name=nil)
      @id, @name, @mutes = id, name, mutes
      generate_name(channels) unless name
    end

    def header
      %Q{%s "#{name}" 128 -1 0 0 1} % [Version]
    end

    def output
      [header.ljust(127)] + @mutes.map.with_index do |mute, i|
        %q{/ch/%02d/mix/on %s} % [i+1, mute ? 'ON' : 'OFF']
      end
    end

    def show_line
      %q{snippet/%03d "%s" 128 -1 0 0 1} % [id, name]
    end

    def ===(other)
      @mutes === other.instance_variable_get(:@mutes)
    end

    private
    def generate_name(channels)
      names = channels.zip(@mutes).map do |c, m|
        c.name[0..1] if m
      end.compact
      names << 'All Off' if names.empty?
      names[4] = '+'+(names.size - 4).to_s if names.size > 5
      @name = names[0..4].join(' ')
    end

  end

end
