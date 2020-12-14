defmodule Shuttle do
  def problem_one do
    {fastest_id, time_till_next} =
      active_shuttles()
      |> Enum.map(fn {frequency, _idx} -> {frequency, frequency - rem(1_002_394, frequency)} end)
      |> Enum.min_by(fn {_frequency, time_till_next} -> time_till_next end)

    fastest_id * time_till_next
  end

  def problem_two do
    active_shuttles()
    |> Enum.sort_by(fn {frequency, _offset} -> -frequency end)
    |> Enum.reduce(nil, fn
      {frequency, offset}, nil ->
        {frequency, frequency - offset}

      {frequency, offset}, {combined_frequency, start} ->
        combined_frequency_cycle_count =
          0..frequency
          |> Enum.find(fn n ->
            v = n * combined_frequency + offset + start
            v > 0 and rem(v, frequency) == 0
          end)

        new_frequency_cycle_count =
          div(combined_frequency_cycle_count * combined_frequency + offset + start, frequency)

        {frequency * combined_frequency, new_frequency_cycle_count * frequency - offset}
    end)
  end

  def active_shuttles do
    "13,x,x,41,x,x,x,37,x,x,x,x,x,419,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,19,x,x,x,23,x,x,x,x,x,29,x,421,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,17"
    |> String.split(",")
    |> Enum.with_index()
    |> Enum.filter(fn {str, _idx} -> str != "x" end)
    |> Enum.map(fn {str, idx} -> {String.to_integer(str), idx} end)
  end
end
