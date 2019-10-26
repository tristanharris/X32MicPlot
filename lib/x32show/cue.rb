module X32Show

  class Cue

    attr_reader :id, :snippet

    def initialize(id, num, comment, snippet)
      @id, @num, @comment, @snippet = id, num.to_f, comment, snippet
      raise "Too many decimal places in cue number #{num}" if @num*100 != (@num*100).to_i
    end

    def show_line
      %q{cue/%03d %d "%s" 0 -1 %d 0 1 0 0} % [id, @num*100, @comment, snippet.id]
    end

    def as_json
      {id: id, num: @num, comment: @comment, mutes: snippet.as_json}
    end

  end

end
