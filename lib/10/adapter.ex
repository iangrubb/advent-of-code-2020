defmodule Adapter do
  def problem_one do
    %{one: one, three: three} =
      ordered_joltages()
      |> Enum.reduce(%{one: 0, two: 0, three: 0, prev: 0}, fn number, %{prev: prev} = diff_map ->
        diff_map = Map.put(diff_map, :prev, number)

        case number - prev do
          3 -> Map.put(diff_map, :three, diff_map.three + 1)
          2 -> Map.put(diff_map, :two, diff_map.two + 1)
          1 -> Map.put(diff_map, :one, diff_map.one + 1)
        end
      end)

    one * (three + 1)
  end

  def problem_two do
    [{_, path_count} | _] =
      ordered_joltages()
      |> Enum.reduce([{0, 1}], fn number, previous ->
        path_count =
          previous
          |> Enum.take_while(fn {prev_number, _path_count} -> prev_number >= number - 3 end)
          |> Enum.reduce(0, fn {_prev_number, path_count}, acc -> acc + path_count end)

        [{number, path_count} | previous]
      end)

    path_count
  end

  def stream_joltages do
    Path.join(__DIR__, "input.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
  end

  def ordered_joltages do
    stream_joltages()
    |> Enum.to_list()
    |> Enum.sort()
  end
end
