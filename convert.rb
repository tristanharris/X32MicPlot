require_relative 'lib/x32show'

show = X32Show::Show.new('Sweeney Todd')
show.load_csv('testdata/ST/Sweeney Todd Mic Cues.csv')
show.save
