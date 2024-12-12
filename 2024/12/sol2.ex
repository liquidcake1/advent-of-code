defmodule Sol do

  # basic defintion
  def solve(filename) do
    contents = File.read!(filename)
    lines = String.split(contents, "\n")
#     IO.inspect(
#       List.to_tuple( 
#         List.delete_at(
#           (for x <-lines, do: List.to_tuple(
#             List.delete_at(tl(String.split(x, "")), String.length(x))
#           )), length(lines)-1)))
    split_lines = List.delete_at(
        (for x <-lines, do: (
                             List.delete_at(tl(String.split(x, "")), String.length(x))
                            )), length(lines)-1)
    IO.inspect(split_lines)
    {regions, region_map} = explore_right(split_lines, nil, 0, %{}, [])
    IO.inspect({regions, region_map})
    {final_regions, rmap, final_region_map} = explore_down(transpose(split_lines), nil, regions, %{}, transpose(region_map), [])
    IO.inspect({final_regions, rmap, final_region_map})
    IO.inspect(Enum.sum(for {perim, _sides, area} <- Map.values(final_regions), do: perim * area))
    IO.inspect(Enum.sum(for {_perim, sides, area} <- Map.values(final_regions), do: sides * area))
  end

  def transpose(a) do
    for x <- Enum.zip(a), do: Tuple.to_list(x)
  end
 
  def explore_right([], _last_line, _current_region, regions, rmap) do
    {regions, Enum.reverse(rmap)}
  end
  def explore_right([line|lines], nil, current_region, regions, rmap) do
    explore_right([line|lines], (for _ <- line, do: nil), current_region, regions, rmap)
  end
  def explore_right([line|lines], last_line, current_region, regions, rmap) do
    {new_curr, new_regions, new_rmap} = explore_right1(line, last_line, regions, current_region)
    explore_right(lines, line, new_curr, new_regions, [new_rmap|rmap])
  end

  def explore_right1([sym|rest], [last_sym|lrest], regions, current_region) do
    new_region = current_region + 1
    sides = if sym == last_sym do 0 else 1 end
    explore_right_([sym|rest], [last_sym|lrest], Map.put(regions, new_region, {1, sides, 0}), [new_region])
  end 
  def explore_right_([sym, sym|rest], [_last_sym|lrest], regions, rmap=[current_region|_]) do
    {perim, sides, area} = regions[current_region]
    explore_right_([sym|rest], lrest, %{regions | current_region => {perim, sides, area + 1}}, [current_region|rmap])
  end 
  def explore_right_([sym1, sym2|rest], [last_sym1, last_sym2|lrest], regions, rmap=[current_region|_]) do
    new_region = current_region + 1
    {perim, sides, area} = regions[current_region]
    sides1 = if sym1 == last_sym1 and last_sym1 != last_sym2 do 0 else 1 end
    sides2 = if sym2 == last_sym2 and last_sym1 != last_sym2 do 0 else 1 end
    explore_right_(
      [sym2|rest], [last_sym2|lrest],
      Map.put(%{regions | current_region => {perim + 1, sides + sides1, area + 1}},
             new_region, {1, sides2, 0}),
      [new_region|rmap])
  end
  def explore_right_([sym], [last_sym], regions, rmap=[current_region|_]) do
    extra_sides = if sym == last_sym do 0 else 1 end
    {perim, sides, area} = regions[current_region]
    {current_region, %{regions | current_region => {perim + 1, sides + extra_sides, area + 1}}, Enum.reverse(rmap)}
  end

  def explore_down([], _last_line, regions, rmap, [], rout) do
    {regions, rmap, Enum.reverse(rout)}
  end
  def explore_down([line|lines], nil, regions, rmap, [rline|rin], rout) do
    explore_down([line|lines], (for _ <- line, do: nil), regions, rmap, [rline|rin], rout)
  end
  def explore_down([line|lines], last_line, regions, rmap, [rline|rin], rout) do
    # rmap = old -> new map
    {new_regions, new_rmap, new_rline} = explore_down1(line, last_line, rmap, regions, rline)
    explore_down(lines, line, new_regions, new_rmap, rin, [new_rline|rout])
  end

  def rlookup(map, key) do
    case Map.fetch(map, key) do
      :error -> key
      {:ok, new} -> rlookup(map, new)
    end
  end

  def explore_down1([sym|rest], [last_sym|lrest], rmap, regions, [new_region_base|rin]) do
    new_region = rlookup(rmap, new_region_base)
    {perim, sides, area} = regions[new_region]
    extra_sides = if sym == last_sym do 0 else 1 end
    explore_down_([sym|rest], [last_sym|lrest], rmap, %{regions | new_region => {perim+1, sides + extra_sides, area}}, [new_region|rin], [])
  end 
  def explore_down_([sym, sym|rest], [_last_sym|lrest], rmap, regions, [current_region, current_region|rin], rout) do
    {perim, sides, area} = regions[current_region]
    explore_down_([sym|rest], lrest, rmap, %{regions | current_region => {perim, sides, area}}, [current_region|rin], [current_region|rout])
  end 
  def explore_down_([sym, sym|rest], [last_sym|lrest], rmap, regions, [old_region, new_region_base|rin], rout) do
    case rlookup(rmap, new_region_base) do
      ^old_region ->
        IO.inspect({"mapping", new_region_base, :to, old_region, :via, rmap})
        explore_down_([sym, sym|rest], [last_sym|lrest], rmap, regions, [old_region, old_region|rin], rout)
      new_region ->
        # Merge regions
        {old_perim, old_sides, old_area} = regions[old_region]
        {new_perim, new_sides, new_area} = regions[new_region]
        new_regions = Map.delete(
          %{regions | new_region => {old_perim + new_perim, old_sides + new_sides, old_area + new_area}},
          old_region
        )
        new_rmap = Map.put(rmap, old_region, new_region)
        IO.inspect({"deleted", old_region, new_region, new_regions, [0|rin]})
        explore_down_([sym|rest], lrest, new_rmap, new_regions, [new_region|rin], [old_region|rout])
    end
  end 
  def explore_down_([sym1, sym2|rest], [last_sym1, last_sym2|lrest], rmap, regions, [prev_region, new_region_base|rin], rout) do
    new_region = rlookup(rmap, new_region_base)
    {prev_perim, prev_sides, prev_area} = regions[prev_region]
    {next_perim, next_sides, next_area} = regions[new_region]
    prev_extra = if sym1 == last_sym1 and last_sym1 != last_sym2 do 0 else 1 end
    next_extra = if sym2 == last_sym2 and last_sym1 != last_sym2 do 0 else 1 end
    explore_down_([sym2|rest], [last_sym2|lrest], rmap,
    %{regions | prev_region => {prev_perim + 1, prev_sides + prev_extra, prev_area},
      new_region => {next_perim + 1, next_sides + next_extra, next_area}},
    [new_region|rin], [prev_region|rout])
  end
  def explore_down_([sym], [last_sym], rmap, regions, [old_region], rout) do
    extra_sides = if sym == last_sym do 0 else 1 end
    {perim, sides, area} = regions[old_region]
    new_regions = %{regions | old_region => {perim + 1, sides + extra_sides, area}}
    {new_regions, rmap, Enum.reverse(rout)}
  end
end


[filename] = System.argv()
Sol.solve(filename)
