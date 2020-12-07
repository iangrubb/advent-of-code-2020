defmodule Customs do
  def problem_one do
    stream_groups()
    |> Stream.map(&submission_map_union/1)
    |> Stream.map(&count_keys/1)
    |> Stream.scan(0, fn count, total -> count + total end)
    |> Enum.at(-1)
  end

  def problem_two do
    stream_groups()
    |> Stream.map(&submission_map_intersection/1)
    |> Stream.map(&count_keys/1)
    |> Stream.scan(0, fn count, total -> count + total end)
    |> Enum.at(-1)
  end

  def submission_map_union(group) do
    group
    |> Enum.reduce(%{}, fn submission, union ->
      submission
      |> Map.keys()
      |> Enum.reduce(union, fn key, union -> Map.put(union, key, true) end)
    end)
  end

  def submission_map_intersection(group) do
    group
    |> Enum.reduce(fn submission, intersection ->
      intersection
      |> Map.keys()
      |> Enum.reduce(%{}, fn key, new_intersection ->
        case Map.get(submission, key) do
          nil -> new_intersection
          true -> Map.put(new_intersection, key, true)
        end
      end)
    end)
  end

  def count_keys(map) do
    map
    |> Map.keys()
    |> Enum.count()
  end

  def unique_question_count(group) do
    group
    |> Enum.reduce(%{}, fn person, map ->
      person
      |> String.split("")
      |> Enum.filter(fn char -> char != "" end)
      |> Enum.reduce(map, fn char, map ->
        case Map.get(map, char) do
          true -> map
          nil -> Map.put(map, char, true)
        end
      end)
    end)
    |> Map.keys()
    |> Enum.count()
  end

  def stream_lines do
    Path.join(__DIR__, "input.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end

  def stream_groups do
    stream_lines()
    |> Stream.chunk_while(
      [],
      fn row, answers ->
        case row do
          "" -> {:cont, answers, []}
          _ -> {:cont, [row | answers]}
        end
      end,
      fn answers -> {:cont, answers, []} end
    )
    |> Stream.map(fn group -> Enum.map(group, &build_submission_map/1) end)
  end

  def build_submission_map(submission) do
    submission
    |> String.split("")
    |> Enum.reduce(%{}, fn char, map ->
      case char do
        "" -> map
        _ -> Map.put(map, char, true)
      end
    end)
  end
end
