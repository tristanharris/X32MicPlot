module X32Show

  class Cue

    attr_reader :id, :snippet

    def initialize(id, num, comment, snippet)
      @id, @num, @comment, @snippet = id, num.to_i, comment, snippet
    end

    def show_line
      %q{cue/%03d %d "%s" 0 -1 %d 0 1 0 0} % [id, @num*100, @comment, snippet.id]
    end

  end

end
