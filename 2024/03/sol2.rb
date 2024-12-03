re = /(do\(\)|don't\(\)|mul\((\d+),(\d+)\))/
text = $stdin.read
matches = text.scan(re)
printf "%s\n", matches
total = 0
total2 = 0
on = true
matches.each do |match|
  if match[0] == "do()" then
    on = true
  elsif match[0] == "don't()" then
    on = false
  elsif on then
    total2 = total2 + match[1].to_i * match[2].to_i 
  end
  total = total + match[1].to_i * match[2].to_i 
end
puts total
puts total2
