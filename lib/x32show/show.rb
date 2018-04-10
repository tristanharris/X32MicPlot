require 'csv'
require 'fileutils'

module X32Show

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

end
