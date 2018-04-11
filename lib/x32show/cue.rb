module X32Show

  class Cue

    attr_reader :snippet

    def initialize(num, comment, snippet)
      @num, @comment, @snippet = num.to_i, comment, snippet
    end

    def show_line(counter)
      %q{cue/%03d %d "%s" 0 -1 %d 0 1 0 0} % [counter, @num*100, @comment, snippet.id]
    end

  end

end
