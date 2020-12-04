defmodule ExpenseReport do
  def two_sum() do
    stream_numbers_from_file()
    |> scan_for_pair_totaling(2020)
    |> multiply_all()
  end

  def three_sum() do
    stream_numbers_from_file()
    |> scan_until_found([], fn number, previous_numbers ->
      sub_stream_result =
        previous_numbers
        |> Stream.take_every(1)
        |> scan_for_pair_totaling(2020 - number)

      case sub_stream_result do
        nil -> {[number | previous_numbers], nil}
        pair -> {previous_numbers, [number | pair]}
      end
    end)
    |> multiply_all()
  end

  def scan_for_pair_totaling(stream, total) do
    stream
    |> scan_until_found(%{}, fn number, number_map ->
      {Map.put(number_map, number, number), check_map_for_pair(total, number_map, number)}
    end)
  end

  defp scan_until_found(stream, initial_accumulator, scanner) do
    stream
    |> Stream.scan({initial_accumulator, nil}, fn element, {accumulator, foundElement} ->
      scanner.(element, accumulator)
    end)
    |> Stream.drop_while(fn {_accumulator, result} -> result == nil end)
    |> Stream.map(fn {_accumulator, result} -> result end)
    |> Stream.concat(Stream.take([nil], 1))
    |> Stream.take(1)
    |> Enum.to_list()
    |> Enum.at(0)
  end

  defp stream_numbers_from_file() do
    Path.join(__DIR__, "input.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
  end

  defp check_map_for_pair(total, number_map, number) do
    case Map.get(number_map, total - number) do
      nil -> nil
      paired_number -> [number, paired_number]
    end
  end

  defp multiply_all(nums), do: Enum.reduce(nums, 1, fn number, acc -> number * acc end)
end
