data := ReadAll(InputTextFile("input6"));
lines := SplitString(data, "\n");
times := SplitString(NormalizedWhitespace(lines[1]), " ");
distances := SplitString(NormalizedWhitespace(lines[2]), " ");
Remove(times, 1);;
Remove(distances, 1);;
sol := function(t, d)
	detr := (t*t-4*d)^0.5;
	return Int(Ceil((t+detr)/2) - Floor((t-detr)/2) - 1);
end;
prod:=1;
for i in [1..Length(times)] do
	prod := prod * sol(Int(times[i]), Int(distances[i]));
od;
Print(prod, "\n");
Print(sol(Int(Concatenation(times)), Int(Concatenation(distances))));
