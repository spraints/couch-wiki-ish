require 'httparty'
require 'pp'
require 'json'
require 'pathname'

class DB
  include HTTParty
  format :json
  base_uri 'http://localhost:5984/wiki/'

  def self.perform_request(http_method, path, options)
    path = '/' + path unless path =~ /^\//
    #puts "#{http_method} #{path} ..."
    res = super(http_method, path, options)
    #pp res.delegate
    res
  end

  def self.update(doc_id, new_doc)
    new_doc = new_doc.dup
    old_doc = DB.get doc_id
    new_doc['_rev'] = old_doc['_rev'] if old_doc['ok']
    DB.put doc_id, :body => new_doc.to_json
  end

  def self.get_rev(doc_id)
    doc = DB.get doc_id
    if doc['error']
      doc = DB.put doc_id, :body => {}.to_json
    end
    doc['_rev']
  end
end

task :default => :build_db

task :reset_db do
  DB.delete '/'
  DB.put '/'
end

task :create_db do
  DB.put '/'
end

task :build_db => [:views]

def get_view_part(view_def, view_part, dir)
  file_name = "#{dir}/#{view_part}.js"
  if File.exist? file_name
    view_def[view_part] = File.read file_name
  end
end

task :views => :create_db do
  Dir.chdir('db/views') do
    FileList['*'].each do |design_doc|
      doc_id = "_design/#{design_doc}"
      doc = DB.get(doc_id).delegate
      doc = {} if doc['error']
      Dir.chdir(design_doc) do
        FileList['*'].each do |view_name|
          puts "Creating view #{design_doc}/#{view_name}"
          view = {}
          get_view_part(view, 'map', view_name)
          get_view_part(view, 'reduce', view_name)
          doc['views'] ||= {}
          doc['views'][view_name] = view
        end
      end
      res = DB.put doc_id, :body => doc.to_json
      raise "Design doc #{doc_id} could not be created: #{res.inspect}" unless res['ok']
    end
  end
end
