require 'sinatra/base'
require_relative 'lib/x32show'
require 'zip'

class App < Sinatra::Application

  get '/' do
    erb :convert
  end

  post '/convert' do
    redirect to('/') unless params[:csv]
    show = X32Show::Show.new('show')
    begin
      show.load_csv(params[:csv][:tempfile].path)
    rescue CSV::MalformedCSVError => e
      return 'Bad CSV format: ' + e.message
    end
    file = Tempfile.new('zip')
    Dir.mktmpdir do |dir|
      show.save(dir)
      Zip::File.open(file.path, Zip::File::CREATE) do |zipfile|
        Dir[dir+'/*/*'].each do |filename|
          zipfile.add(File.join(show.name, File.basename(filename)), filename)
        end
      end
    end
    send_file file.path, type: :zip, disposition: :attachment, filename: show.name+'.zip'
  end

end
