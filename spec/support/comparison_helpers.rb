def same_data_set_value(one, another)
  case one
  when Hash
    result = another.kind_of?(Hash) && one.keys == another.keys
    one.each do |key, value|
      result = result && value == another[key]
    end
    result
  when Array
    result = another.kind_of?(Array)
    one.each_with_index do |e, i|
      result = result && same_data_set_value(e, another[i])
    end
    result
  else
    one == another
  end
end

def data_sets_are_equal(one, another)
  result = true
  one.each do |key, value|
    result = result && same_data_set_value(value, another[key])
  end

  result
end