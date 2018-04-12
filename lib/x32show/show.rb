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
        headers = csv.shift
        headers[2..-1].each do |ch_name|
          @channels.add(ch_name)
        end
        csv.each do |row|
          snippet = @snippets.add(row[2..-1], @channels)
          @cues.add(row[1], row[0], snippet)
        end
      end
      create_channel_setup_scene
    end

    def save
      dir = name
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
          File.open(File.join(dir, name+('.%03d.snp' % cue.id)), 'w') do |snip_h|
            snip_h.puts cue.snippet.output
          end
        end
      end
    end

  end

end
