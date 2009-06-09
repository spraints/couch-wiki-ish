function(doc)
{
  if(doc.topics)
  {
    for(var i = 0; i < doc.topics.length; i++)
    {
      emit(doc.topics[i], doc);
    }
  }
}
