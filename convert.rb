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

  def self.default
    List[:blue]
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

  def self.none
    new('', 1)
  end

  def self.default
    new('Man', 41)
  end

end

class Cue

  attr_reader :snippet

  def initialize(num, comment, mutes)
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
    [header.ljust(127)] + @mutes.map.with_index do |mute, i|
      %q{/ch/%02d/mix/on %s} % [i+1, mute ? 'ON' : 'OFF']
    end
  end

  def show_line(counter)
    %q{snippet/%03d "%s" 128 -1 0 0 1} % [counter, name]
  end

end

class Channel

  attr_reader :num, :name, :icon, :colour

  def initialize(num, name, icon=Icon.default, colour=Colour.default)
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

class Show

  attr_reader :name

  def initialize(name)
    @name = name
    @scenes = []
    @cues = []
    @channels = []
  end

  def output
    [Version, %Q{show "#{name}" 0 0 0 0 0 0 0 0 0 0 "2.04"}]
  end

  def create_channel_setup_scene
    @scenes << Scene.new(name, 'Channel Setup', @channels)
  end

  def load_csv(path)
    CSV.open(path, skip_blanks: true) do |csv|
      headers = csv.shift
      headers[2..-1].each.with_index do |ch_name, i|
        @channels << Channel.new(i+1, ch_name)
      end
      csv.each do |row|
        @cues << Cue.new(row[1], row[0], row[2..-1])
      end
    end
    create_channel_setup_scene
  end

  def save
    dir = name
    FileUtils.mkdir_p(dir)
    File.open(File.join(dir, name+'.shw'), 'w') do |show_h|
      show_h.puts output
      @scenes.each.with_index do |scene, i|
        show_h.puts scene.show_line(i)
        File.open(File.join(dir, name+('.%03d.scn' % i)), 'w') do |scene_h|
          scene_h.puts scene.output
        end
      end
      @cues.each.with_index do |cue, i|
        show_h.puts cue.show_line(i)
        show_h.puts cue.snippet.show_line(i)
        File.open(File.join(dir, name+('.%03d.snp' % i)), 'w') do |snip_h|
          snip_h.puts cue.snippet.output
        end
      end
    end
  end

end

show = Show.new('Sweeney Todd')
show.load_csv('testdata/ST/Sweeney Todd Mic Cues.csv')
show.save
