require 'csv'
require 'fileutils'

Version = '#2.6#'

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

end

class Icon

  attr_reader :name, :code

  def initialize(name, code)
    @name, @code = name, code
  end

  def self.random
    new('image', (1..74).to_a.sample)
  end

  def none
    new('', 1)
  end

end

class Cue

  attr_reader :snippet

  def initialize(num, comment, *mutes)
    @num, @comment, @snippet = num.to_i, comment, Snippet.new(comment, mutes)
  end

  def show_line(counter)
    %q{cue/%03d %d "%s" 0 -1 %d 0 1 0 0} % [counter, @num*100, @comment, counter]
  end

end

class Snippet

  attr_reader :name

  def initialize(name, mutes)
    @name, @mutes = name, mutes
  end

  def header
    %Q{%s "#{name}" 128 -1 0 0 1} % [Version]
  end

  def output
    [header] + @mutes.map.with_index do |mute, i|
      %q{/ch/%02d/mix/on %s} % [i+1, mute ? 'ON' : 'OFF']
    end
  end

  def show_line(counter)
    %q{snippet/%03d "%s" 128 -1 0 0 1} % [counter, name]
  end

end

class Channel

  attr_reader :num, :name, :icon, :colour

  def initialize(num, name, icon=Icon.random, colour=Colour.random)
    @num, @name, @icon, @colour = num, name, icon, colour
  end

  def output
    %q{/ch/%02d/config "%s" %d %s %d} % [num, name.gsub(/\s+/, ' ')[0..11].strip, icon.code, colour.code, visible ? 1 : 0]
  end

  def visible
    #show name on channel strip
    true
  end

end

class Scene

  attr_reader :name, :note

  def initialize(name, note, channels)
    @name, @note, @channels = name, note, channels
  end

  def output
    [header] + @channels.map.with_index do |name, i|
      Channel.new(i, name).output
    end
  end

  def show_line(counter)
    %q{scene/%03d "%s" "%s" %%000000000 1} % [counter, name, note]
  end

  def header
    %q{%s "%s" "%s" %%000000000 1} % [Version, name, note]
  end

end

class Show

  attr_reader :name

  def initialize(name)
    @name = name
  end

  def output
    [Version, %Q{show "#{name}" 0 0 0 0 0 0 0 0 0 0 "2.04"}]
  end

end

show = Show.new('Sweeney Todd')
FileUtils.mkdir_p(show.name)
File.open(File.join(show.name, show.name+'.shw'), 'w') do |show_h|
  show_h.puts show.output

  counter = 0
  CSV.foreach('testdata/ST/Sweeney Todd Mic Cues.csv', headers: true, skip_blanks: true) do |row|
    if (counter == 0)
      scene = Scene.new(show.name, 'Channel Setup', row.headers[2..-1])
      show_h.puts scene.show_line(counter)
      File.open(File.join(show.name, show.name+'.%03d.scn'%counter), 'w') do |scene_h|
        scene_h.puts scene.output
      end
    end
    cue = Cue.new(*row.fields)
    show_h.puts cue.show_line(counter)
    show_h.puts cue.snippet.show_line(counter)
    File.open(File.join(show.name, show.name+'.%03d.snp'%counter), 'w') do |snip_h|
      snip_h.puts cue.snippet.output
    end
    counter += 1
  end
end
