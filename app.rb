require 'sinatra/base'
require_relative 'lib/x32show'
require 'zip'

class App < Sinatra::Application
  enable :inline_templates

  get '/' do
    erb :index
  end

  post '/convert' do
    redirect to('/') unless params[:csv]
    show = X32Show::Show.new('show')
    show.load_csv(params[:csv][:tempfile].path)
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

__END__

@@ index
<!DOCTYPE html>
<html>
  <head>
    <title>X32 Plot Converter</title>
  </head>
  <body>
    <h1>X32 Plot Converter</h1>
    <form method='post' action='convert' enctype='multipart/form-data'>
      <input type='file' name='csv' accept='.csv'>
      <input type='submit'>
    </form>
    <p>
      <h3>Examples</h3>
      <a href='/example_cues.ods'>OpenOffice spreadsheet</a>
      <a href='/example_cues.csv'>CSV file</a>
    </p>
  </body>
</html>
