defmodule BoardingPass do
  def problem_one do
    stream_boarding_passes()
    |> Stream.map(&determine_seat_coordinates/1)
    |> Stream.map(&determine_seat_id/1)
    |> Stream.scan(0, fn curr, highest -> max(curr, highest) end)
    |> Enum.at(-1)
  end

  def problem_two do
    stream_boarding_passes()
    |> Stream.map(&determine_seat_coordinates/1)
    |> Stream.map(&determine_seat_id/1)
    |> Enum.to_list()
    |> Enum.sort()
    |> Enum.reduce_while(nil, fn curr, previous ->
      cond do
        previous == nil -> {:cont, curr}
        curr == previous + 1 -> {:cont, curr}
        true -> {:halt, previous + 1}
      end
    end)
  end

  defp determine_seat_coordinates(pass) do
    {row, column, _step_size} =
      pass
      |> String.split("")
      |> Enum.reduce({0, 0, 64}, fn letter, {row, column, step_size} ->
        new_step_size = if step_size == 1, do: 4, else: div(step_size, 2)

        case letter do
          "F" -> {row, column, new_step_size}
          "B" -> {row + step_size, column, new_step_size}
          "L" -> {row, column, new_step_size}
          "R" -> {row, column + step_size, new_step_size}
          "" -> {row, column, step_size}
        end
      end)

    {row, column}
  end

  defp determine_seat_id({row, column}), do: row * 8 + column

  defp stream_boarding_passes do
    Path.join(__DIR__, "input.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end
end
