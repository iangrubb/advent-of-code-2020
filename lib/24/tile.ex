defmodule Tile do
  def problem_one do
    build_initial_tile_map()
    |> Map.to_list()
    |> Enum.filter(fn {_, black?} -> black? end)
    |> Enum.count()
  end

  def problem_two do
    0..99
    |> Enum.reduce(build_initial_tile_map(), fn _, tiles -> update_tile_map(tiles) end)
    |> Map.to_list()
    |> Enum.count()
  end

  def update_tile_map(tiles) do
    tiles
    |> Map.to_list()
    |> Enum.reduce(%{}, fn
      {_coordinate, false}, processed_tiles ->
        processed_tiles

      {{x, y} = coordinate, true}, processed_tiles ->
        {_, neighboor_count} = Map.get(processed_tiles, coordinate, {false, 0})

        processed_with_current = Map.put(processed_tiles, coordinate, {true, neighboor_count})

        [{1, 0}, {0, 1}, {1, -1}, {-1, 1}, {-1, 0}, {0, -1}]
        |> Enum.reduce(processed_with_current, fn {dx, dy}, map ->
          {color, count} = Map.get(map, {dx + x, dy + y}, {false, 0})
          Map.put(map, {dx + x, dy + y}, {color, count + 1})
        end)
    end)
    |> Map.to_list()
    |> Enum.reduce(%{}, fn {coordinate, {black?, count}}, new_tiles ->
      cond do
        black? and count > 0 and count < 3 -> Map.put(new_tiles, coordinate, true)
        not black? and count == 2 -> Map.put(new_tiles, coordinate, true)
        true -> new_tiles
      end
    end)
  end

  def count_adjacent_black(tiles, {x, y}) do
    [{1, 0}, {0, 1}, {1, -1}, {-1, 1}, {-1, 0}, {0, -1}]
    |> Enum.map(fn {dx, dy} -> Map.get(tiles, {dx + x, dy + y}, false) end)
    |> Enum.filter(fn black? -> black? end)
    |> Enum.count()
  end

  def build_initial_tile_map() do
    stream_tiles()
    |> Stream.scan(%{}, fn instruction, flip_map ->
      coordinate = traverse_path(instruction)

      flip_map
      |> Map.put(
        coordinate,
        not Map.get(flip_map, coordinate, false)
      )
    end)
    |> Enum.at(-1)
  end

  def traverse_path(path) do
    path
    |> String.split("")
    |> Enum.filter(fn str -> str != "" end)
    |> Enum.reduce({0, 0}, fn
      "n", {x, y} -> {x, y, "n"}
      "s", {x, y} -> {x, y, "s"}
      "e", {x, y} -> {x + 1, y}
      "w", {x, y} -> {x - 1, y}
      "e", {x, y, "n"} -> {x, y + 1}
      "e", {x, y, "s"} -> {x + 1, y - 1}
      "w", {x, y, "n"} -> {x - 1, y + 1}
      "w", {x, y, "s"} -> {x, y - 1}
    end)
  end

  def stream_tiles do
    Path.join(__DIR__, "input.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end
end
