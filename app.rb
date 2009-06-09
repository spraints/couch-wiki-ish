require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'httparty'
require 'json'
require 'pp'
require 'date'

class DB
  include HTTParty
  base_uri 'http://localhost:5984/wiki/'
  format :json

  def self.perform_request(http_method, path, options)
    path = '/' + path unless path =~ /^\//
    path = URI.encode path
    puts "#{http_method} #{path} #{options.inspect}"
    res = super(http_method, path, options)
    pp res.delegate
    res
  end

  def self.save(id, doc)
    doc = doc.merge :modified => DateTime.now
    case id
    when '', nil
      self.post '/', :body => doc.to_json
    else
      self.put id, :body => doc.to_json
    end
  end
end

get '/' do
  topics_result = DB.get('_design/topics/_view/all', :query => {:group => true})
  @topics = topics_result['rows'].collect { |row| row['key'] }
  @entry = {}
  haml :welcome
end

helpers do
  def build_entry
    {
      'topics' => params[:topics].split(',').collect { |s| s.strip },
      'contents' => params[:contents]
    }
  end
end

post '/entry' do
  @entry = build_entry
  res = DB.save(params[:id], @entry)
  if(res['ok'])
    redirect(URI.escape("/entry/#{res['id']}"))
  else
    @error = "Unable to save the document: #{res.inspect}"
    haml :welcome
  end
end

post '/entry/:id' do
  @entry = build_entry.merge '_rev' => params[:rev]
  res = DB.save(params[:id], @entry)
  if(res['ok'])
    redirect(URI.escape("/entry/#{res['id']}"))
  else
    @error = "Unable to save the document: #{res.inspect}"
    haml :edit
  end
end

get '/entry/:id' do
  @entry = DB.get params[:id]
  @entry['error'] ? pass : haml(:entry)
end

get '/entry/:id/edit' do
  @entry = DB.get params[:id]
  haml :edit
end

post '/entry/:id/delete' do
  res = DB.delete params[:id], :query => {:rev => params['rev']}
  if(res['ok'])
    redirect '/'
  else
    @error = "Unable to save the document: #{res.inspect}"
    @entry = DB.get params[:id]
    haml :entry
  end
end

get '/topic/:name' do
  @related_topics = DB.get('_design/topics/_view/related', :query => {:group => true, :startkey => [params[:name]].to_json, :endkey => [params[:name],{}].to_json})['rows'].collect { |row| row['key'][1] }
  @entries = DB.get('_design/entries/_view/by_topic', :query => {:key => params[:name].to_json})['rows'].collect { |row| row['value'] }
  haml :topic
end

[:screen, :print, :ie].each do |sheet|
  get "/#{sheet}.css" do
    content_type 'text/css'
    sass sheet
  end
end
