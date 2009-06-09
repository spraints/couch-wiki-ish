function(key, values)
{
  var i = 1;
  values.sort();
  while(i < values.length)
  {
    if(values[i - 1] == values[i])
    {
      values.splice(i, 1);
    }
    else
    {
      i++;
    }
  }
  return values;
}
