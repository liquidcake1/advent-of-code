defmodule Sol do

  # basic defintion
  def solve(filename) do
    contents = File.read!(filename)
    lines = String.split(contents, "\n")
    answers = for line <- lines, do: solve_line(line, 1)
    IO.inspect(["part 1", Enum.sum(answers)])
    answers2 = for line <- lines, do: solve_line(line, 5)
    IO.inspect(["part 2", Enum.sum(answers2)])
  end

  def solve_line("", _), do: 0
  def solve_line(line, replicas) do
    [record, runs_str] = String.split(line, " ")
    runs = for run <- String.split(runs_str, ",") do
      {i, ""} = Integer.parse(run)
      i
    end
    runs2 = List.flatten(List.duplicate(runs, replicas))
    record2 = String.duplicate(record <> "?", replicas - 1) <> record
    #IO.inspect(["solve_line in", record2, runs2])
    {count, _} = satisfy_count(record2, runs2, %{})
    #IO.inspect(["solve_line result", record2, runs2, count])
    count
  end

  def satisfy_count(record, [], cache) do
    #IO.inspect(["tail", record])
    n = if String.contains?(record, "#") do
      0
    else
      1
    end
    {n, cache}
  end
  def satisfy_count(record, [run|runs], cache) do
    key = {record, [run|runs]}
    case Map.get(cache, key) do
      nil ->
        #IO.inspect(["loop", record, run, runs, rests(record, run), Kernel.map_size(cache)])
        {count, cache3} = List.foldl(
          rests(record, run),
          {0, cache},
          fn rest, {n, cache1} ->
            {n2, cache2} = satisfy_count(rest, runs, cache1)
            {n + n2, cache2}
          end
        )
        #IO.inspect(["loop result", record, run, runs, count, Kernel.map_size(cache3)])
        {count, Map.put(cache3, key, count)}
      val ->
        #IO.inspect(["loop cache hit", record, run, runs])
        {val, cache}
    end
  end

  def rests("." <> rest, run), do: rests(rest, run)
  def rests(rest, run) when byte_size(rest) < run, do: []
  def rests(record, run) do
    #IO.inspect(["rests", record, run, String.contains?(String.slice(record, 0, run), "."), String.slice(record, run, 1), String.contains?(String.slice(record, 0, run), ".") and String.slice(record, run, 1) != "#"])
    # There should be run non-"." symbols, then a non-"#"
    tail = case record do
      "#" <> _ -> []
      _ -> rests(String.slice(record, 1, 2312321), run)
    end
    cond = not String.contains?(String.slice(record, 0, run), ".") and String.slice(record, run, 1) != "#"
    if cond do
      #IO.inspect("ok")
      [String.slice(record, run + 1, 2112312)|tail]
    else
      tail
    end
  end

end


[filename] = System.argv()
Sol.solve(filename)

