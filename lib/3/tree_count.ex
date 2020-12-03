defmodule TreeCount do
  def aoc_answer do
    [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]
    |> Enum.map(&trees_on_path/1)
    |> Enum.reduce(1, fn tree_count, total -> tree_count * total end)
  end

  def trees_on_path({slope_x, slope_y}) do
    stream_map_rows(slope_y)
    |> Stream.map(fn row -> String.trim(row) end)
    |> Stream.scan({0, 0}, fn row, {distance, tree_count} ->
      {distance + slope_x, tree_count + detect_tree(row, distance)}
    end)
    |> Stream.map(fn {_distance, tree_count} -> tree_count end)
    |> Enum.at(-1)
  end

  defp stream_map_rows(frequency) do
    Path.join(__DIR__, "map.txt")
    |> File.stream!()
    |> Stream.take_every(frequency)
  end

  defp detect_tree(row, distance) do
    case String.at(row, rem(distance, String.length(row))) do
      "#" -> 1
      "." -> 0
    end
  end
end
