require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'httparty'
require 'json'
require 'pp'

class DB
  include HTTParty
  base_uri 'http://localhost:5984/wiki/'
  format :json

  def self.perform_request(http_method, path, options)
    path = '/' + path unless path =~ /^\//
    puts "#{http_method} #{path} #{options.inspect}"
    res = super(http_method, path, options)
    pp res.delegate
    res
  end

  def self.create(id, doc)
    res = case id
      when '', nil
        self.post '/', :body => doc.to_json
      else
        self.put id, :body => doc.to_json
      end
    res['ok']
  end
end

get '/' do
  topics_result = DB.get('_design/topics/_view/all', :query => {:group => true})
  @topics = topics_result['rows'].collect { |row| row['key'] }
  haml :welcome
end

post '/entry' do
  id = params[:id]
  topics = params[:topic].split(',')
  contents = params[:contents]
  if DB.create id, :topics => topics, :contents => contents
    redirect '/'
  else
    @error = 'Unable to save the document.'
    haml :welcome
  end
end

get '/entry/:id' do
  @entry = DB.get params[:id]
  haml :entry
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
