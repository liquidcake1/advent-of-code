re = /mul\((\d+),(\d+)\)/
text = $stdin.read
matches = text.scan(re)
printf "%s\n", matches
total = 0
on = true
matches.each do |match|
  total = total + match[0].to_i * match[1].to_i 
end
puts total
