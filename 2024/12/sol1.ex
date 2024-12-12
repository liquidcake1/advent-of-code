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
    {regions, region_map} = explore_right(split_lines, 0, %{}, [])
    IO.inspect({regions, region_map})
    {final_regions, rmap, final_region_map} = explore_down(transpose(split_lines), regions, %{}, transpose(region_map), [])
    IO.inspect({final_regions, rmap, final_region_map})
    IO.inspect(Enum.sum(for {perim, area} <- Map.values(final_regions), do: perim * area))
  end

  def transpose(a) do
    for x <- Enum.zip(a), do: Tuple.to_list(x)
  end
 
  def explore_right([], _current_region, regions, rmap) do
    {regions, Enum.reverse(rmap)}
  end
  def explore_right([line|lines], current_region, regions, rmap) do
    {new_curr, new_regions, new_rmap} = explore_right_(line, nil, current_region, regions, [])
    explore_right(lines, new_curr, new_regions, [new_rmap|rmap])
  end

  def explore_right_([], _last_symbol, current_region, regions, rmap) do
    {current_region, regions, Enum.reverse(rmap)}
  end
  def explore_right_([sym|rest], nil, current_region, regions, rmap) do
    new_region = current_region + 1
    explore_right_(rest, sym, new_region, Map.put(regions, new_region, {2, 1}), [new_region|rmap])
  end 
  def explore_right_([sym|rest], sym, current_region, regions, rmap) do
    {perim, area} = regions[current_region]
    explore_right_(rest, sym, current_region, %{regions | current_region => {perim, area + 1}}, [current_region|rmap])
  end 
  def explore_right_([sym|rest], _last_symbol, current_region, regions, rmap) do
    new_region = current_region + 1
    explore_right_(rest, sym, new_region, Map.put(regions, new_region, {2, 1}), [new_region|rmap])
  end

  def explore_down([], regions, rmap, [], rout) do
    {regions, rmap, Enum.reverse(rout)}
  end
  def explore_down([line|lines], regions, rmap, [rline|rin], rout) do
    # rmap = old -> new map
    {new_regions, new_rmap, new_rline} = explore_down_(line, nil, nil, rmap, regions, rline, [])
    explore_down(lines, new_regions, new_rmap, rin, [new_rline|rout])
  end

  def rlookup(map, key) do
    case Map.fetch(map, key) do
      :error -> key
      {:ok, new} -> rlookup(map, new)
    end
  end

  def explore_down_([], _last_symbol, _current_region, rmap, regions, [], rout) do
    {regions, rmap, Enum.reverse(rout)}
  end
  def explore_down_([sym|rest], nil, nil, rmap, regions, [new_region_base|rin], rout) do
    new_region = rlookup(rmap, new_region_base)
    {perim, area} = regions[new_region]
    explore_down_(rest, sym, new_region, rmap, Map.put(regions, new_region, {perim+2, area}), rin, [new_region|rout])
  end 
  def explore_down_([sym|rest], sym, current_region, rmap, regions, [current_region|rin], rout) do
    {perim, area} = regions[current_region]
    explore_down_(rest, sym, current_region, rmap, %{regions | current_region => {perim, area}}, rin, [current_region|rout])
  end 
  def explore_down_([sym|rest], sym, old_region, rmap, regions, [new_region_base|rin], rout) do
    case rlookup(rmap, new_region_base) do
      ^old_region ->
        IO.inspect({"mapping", new_region_base, :to, old_region, :via, rmap})
        explore_down_([sym|rest], sym, old_region, rmap, regions, [old_region|rin], rout)
      new_region ->
        # Merge regions
        {old_perim, old_area} = regions[old_region]
        {new_perim, new_area} = regions[new_region]
        new_regions = Map.delete(
          %{regions | new_region => {old_perim + new_perim, old_area + new_area}},
          old_region
        )
        new_rmap = Map.put(rmap, old_region, new_region)
        IO.inspect({"deleted", old_region, new_region, new_regions, [0|rin]})
        explore_down_(rest, sym, new_region, new_rmap, new_regions, rin, [new_region|rout])
    end
  end 
  def explore_down_([sym|rest], _prev_symbol, _prev_region, rmap, regions, [new_region_base|rin], rout) do
    new_region = rlookup(rmap, new_region_base)
    {perim, area} = regions[new_region]
    explore_down_(rest, sym, new_region, rmap, %{regions | new_region => {perim + 2, area}}, rin, [new_region|rout])
  end
end


[filename] = System.argv()
Sol.solve(filename)
