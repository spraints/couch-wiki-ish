function(doc)
{
  if(doc.topics)
  {
    for(var i = 0; i < doc.topics.length; i++)
    {
      for(var j = 0; j < doc.topics.length; j++)
      {
        if(i != j)
        {
          emit(doc.topics[i], doc.topics[j]);
        }
      }
    }
  }
}
