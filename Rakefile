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
    puts "#{http_method} #{path} ..."
    res = super(http_method, path, options)
    pp res.delegate
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

task :default => :build

task :reset_db do
  DB.delete '/'
  DB.put '/'
end

task :build => [:design_docs, :attachments]

task :design_docs do
  FileList['_design/*.js'].each do |f|
    DB.update f.sub(/.js$/, ''), JSON.parse(File.read(f))
  end
end

task :attachments do
  FileList['_design/*/*'].each do |f|
    puts f
    p = Pathname.new f
    DB.put f + '?rev=' + DB.get_rev(p.dirname), :body => p.read
  end
end
