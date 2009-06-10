function(doc)
{
  if(doc.topics)
  {
    var index = new Document();
    for(var i = 0; i < doc.topics.length; i++)
      index.add(doc.topics[i]);
    index.add(doc.content);
    return index;
  }
  return null;
}
