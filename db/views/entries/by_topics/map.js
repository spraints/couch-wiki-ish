function(doc)
{
  if(doc.topics)
  {
    var permute = function(sorted_topics, start_index, accum)
    {
      for(var i = start_index; i < sorted_topics.length; i++)
      {
        var combined = accum.concat([sorted_topics[i]]);
        emit(combined, doc);
        permute(sorted_topics, i + 1, combined);
      }
    };
    var sorted_topics = doc.topics.concat();
    sorted_topics.sort();
    permute(sorted_topics, 0, []);
  }
}
