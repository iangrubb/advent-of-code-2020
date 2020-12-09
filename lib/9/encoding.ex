defmodule Encoding do
  def problem_one do
    stream_numbers()
    |> stream_with_previous(25)
    |> Stream.filter(fn {current, previous, count} ->
      count == 25 && !summing_pair?(previous, current)
    end)
    |> Stream.map(fn {value, _, _} -> value end)
    |> Enum.at(0)
  end

  def problem_two do
    target_sum = problem_one()

    sequence =
      stream_numbers()
      |> Stream.scan({Queue.create(), 0, false}, fn number, {queue, total, false} ->
        check_for_total(Queue.add(queue, number), total + number, target_sum)
      end)
      |> Stream.filter(fn {_queue, _total, found?} -> found? end)
      |> Stream.map(fn {queue, _total, true} -> queue end)
      |> Enum.at(0)
      |> Queue.to_list()
      |> Enum.sort()

    Enum.at(sequence, 0) + List.last(sequence)
  end

  def check_for_total(queue, total, target_sum) do
    cond do
      total > target_sum ->
        check_for_total(Queue.remove!(queue), total - Queue.first(queue), target_sum)

      total < target_sum ->
        {queue, total, false}

      total == target_sum ->
        {queue, total, true}
    end
  end

  def summing_pair?(numbers, target_sum) do
    ascending = Enum.sort(numbers)
    descending = Enum.reverse(ascending)

    check_for_pair(ascending, descending, target_sum)
  end

  def check_for_pair([], _desc, _target_sum), do: false

  def check_for_pair(_asc, [], _target_sum), do: false

  def check_for_pair(
        [current_asc | remaining_asc] = asc,
        [current_desc | remaining_desc] = desc,
        target_sum
      ) do
    sum = current_asc + current_desc

    cond do
      sum > target_sum -> check_for_pair(asc, remaining_desc, target_sum)
      sum < target_sum -> check_for_pair(remaining_asc, desc, target_sum)
      sum == target_sum -> true
    end
  end

  def stream_with_previous(stream, number) do
    stream
    |> Stream.scan({nil, [], 0}, fn number, {current, previous, previous_count} ->
      cond do
        current == nil ->
          {number, [], 0}

        previous_count < 25 ->
          {number, [current | previous], previous_count + 1}

        true ->
          {number, [current | Enum.take(previous, 24)], 25}
      end
    end)
  end

  def stream_numbers do
    Path.join(__DIR__, "input.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
  end
end
