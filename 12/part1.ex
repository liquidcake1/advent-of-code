# functions are defined inside Modules
defmodule Sol do

  # basic defintion
  def solve(filename) do
    contents = File.read!(filename)
    lines = String.split(contents, "\n")
    answers = for line <- lines, do: solve_line(line)
    IO.inspect(Enum.sum(answers))
  end

  def solve_line(""), do: 0
  def solve_line(line) do
    [record, runs_str] = String.split(line, " ")
    runs = for run <- String.split(runs_str, ",") do
      {i, ""} = Integer.parse(run)
      i
    end
    count = satisfy_count(record, runs)
    IO.inspect(["solve_line result", record, runs, count])
    count
  end

  def satisfy_count(record, []) do
    IO.inspect(["tail", record])
    if String.contains?(record, "#") do
      0
    else
      1
    end
  end
  def satisfy_count(record, [run|runs]) do
    IO.inspect(["loop", record, run, runs, rests(record, run)])
    Enum.sum(for rest <- rests(record, run), do: satisfy_count(rest, runs))
  end

  def rests("." <> rest, run), do: rests(rest, run)
  def rests(rest, run) when byte_size(rest) < run, do: []
  def rests(record, run) do
    IO.inspect(["rests", record, run, String.contains?(String.slice(record, 0, run), "."), String.slice(record, run, 1), String.contains?(String.slice(record, 0, run), ".") and String.slice(record, run, 1) != "#"])
    # There should be run non-"." symbols, then a non-"#"
    tail = case record do
      "#" <> _ -> []
      _ -> rests(String.slice(record, 1, 2312321), run)
    end
    cond = not String.contains?(String.slice(record, 0, run), ".") and String.slice(record, run, 1) != "#"
    if cond do
      IO.inspect("ok")
      [String.slice(record, run + 1, 2112312)|tail]
    else
      tail
    end
  end

end

[filename] = System.argv()
Sol.solve(filename)

