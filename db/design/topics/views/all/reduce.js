function(key, values, rereduce)
{
  if(rereduce)
  {
    return ['rereducing...', key, values];
  }
  return sum(values);
}
