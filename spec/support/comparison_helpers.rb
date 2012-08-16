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

def response_matches(response, expected_data)
  data = JSON.parse(response.body)
  result = true
  data.each do |key, value|
    result = result && same_data_set_value(value, expected_data[key])
  end

  result
end
