module X32Show

  Version = '#2.7#'

  load File.dirname(__FILE__) + '/x32show/show.rb'
  load File.dirname(__FILE__) + '/x32show/channel.rb'
  load File.dirname(__FILE__) + '/x32show/colour.rb'
  load File.dirname(__FILE__) + '/x32show/icon.rb'
  load File.dirname(__FILE__) + '/x32show/cue.rb'
  load File.dirname(__FILE__) + '/x32show/scene.rb'
  load File.dirname(__FILE__) + '/x32show/snippet.rb'

  class IndexedStore

    extend Forwardable

    def_delegators :@data, :each, :map, :zip

    def initialize(klass, offset = 0)
      @data = []
      @klass = klass
      @offset = offset
    end

    def add(*args)
      obj = @klass.new(@data.size + @offset, *args)
      found = @data.find {|a| a === obj}
      if found
        found
      else
        @data << obj
        obj
      end
    end

    def [](id)
      @data[id + @offset]
    end

  end

end
