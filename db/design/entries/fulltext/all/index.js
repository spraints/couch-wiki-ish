function(doc)
{
  if(doc.topics)
  {
    var index = new Document();
    index.add(doc._id);
    for(var i = 0; i < doc.topics.length; i++)
    {
      index.add(doc.topics[i]);
      index.add(doc.topics[i], {"field": "topic"});
    }
    index.add(doc.content);
    try
    {
      var lastModified = new Date();
      lastModified.setTime(Date.parse(doc.modified));
      index.add(lastModified, {"field": "modified"});
    }
    catch(ex) { }
    return index;
  }
  return null;
}
