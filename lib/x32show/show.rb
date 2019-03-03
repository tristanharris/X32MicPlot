require 'csv'
require 'fileutils'

module X32Show

  class Show

    attr_reader :name

    def initialize(name)
      @name = name
      @scenes = IndexedStore.new(Scene)
      @cues = IndexedStore.new(Cue)
      @channels = IndexedStore.new(Channel, 1)
      @snippets = IndexedStore.new(Snippet)
    end

    def output
      [Version, %Q{show "#{name}" 0 0 0 0 0 0 0 0 0 0 "2.04"}]
    end

    def create_channel_setup_scene
      @scenes.add(name, 'Channel Setup', @channels)
    end

    def load_csv(path)
      CSV.open(path, skip_blanks: true) do |csv|
        icons = csv.shift
        @name = icons[0] unless icons[0].empty?
        names = csv.shift
        headers = names.zip icons
        headers[2..-1].each do |ch_name, icon|
          @channels.add(ch_name, Icon[icon])
        end
        csv.each do |row|
          next if row.compact.empty?
          snippet = @snippets.add(row[2..-1], @channels)
          @cues.add(row[1], row[0], snippet)
        end
      end
      create_channel_setup_scene
    end

    def save(dir = '.')
      dir = File.join(dir, name)
      FileUtils.mkdir_p(dir)
      File.open(File.join(dir, name+'.shw'), 'w') do |show_h|
        show_h.puts output
        @scenes.each do |scene|
          show_h.puts scene.show_line
          File.open(File.join(dir, name+('.%03d.scn' % scene.id)), 'w') do |scene_h|
            scene_h.puts scene.output
          end
        end
        @cues.each do |cue|
          show_h.puts cue.show_line
          show_h.puts cue.snippet.show_line
          File.open(File.join(dir, name+('.%03d.snp' % cue.snippet.id)), 'w') do |snip_h|
            snip_h.puts cue.snippet.output
          end
        end
      end
    end

    def to_json
      as_json.to_json
    end

    def as_json
      json = {name: name}
      json[:channels] = @channels.map(&:as_json)
      json[:cues] = @cues.map(&:as_json)
      json
    end

  end

end
