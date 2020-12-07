defmodule Bag do
  def problem_one do
    build_containment_graph()
    |> get_descendants("shiny gold")
    |> Map.keys()
    |> Enum.count()
  end

  def problem_two do
    build_containing_map()
    |> count_contents("shiny gold")
  end

  def count_contents(map, key) do
    Map.get(map, key)
    |> Enum.map(fn {count, color} -> count * (1 + count_contents(map, color)) end)
    |> Enum.reduce(0, fn count, acc -> count + acc end)
  end

  def get_descendants(graph, key), do: add_descendants_to_map(%{}, graph, Map.get(graph, key))

  def add_descendants_to_map(descendants, graph, keys) do
    Enum.reduce(keys, descendants, fn key, descendants ->
      case Map.get(descendants, key) do
        true ->
          descendants

        _ ->
          new_descendants = Map.put(descendants, key, true)

          case Map.get(graph, key) do
            nil -> new_descendants
            children -> add_descendants_to_map(new_descendants, graph, children)
          end
      end
    end)
  end

  def build_containing_map do
    stream_rules()
    |> Stream.scan(%{}, fn {color, contents}, map -> Map.put(map, color, contents) end)
    |> Enum.at(-1)
  end

  def build_containment_graph do
    stream_rules()
    |> Stream.scan(%{}, fn rule, graph -> add_rule_to_graph(rule, graph) end)
    |> Enum.at(-1)
  end

  def add_rule_to_graph({color, contents}, graph) do
    contents
    |> Enum.reduce(graph, fn {_count, contained}, graph ->
      case Map.get(graph, contained) do
        nil -> Map.put(graph, contained, [color])
        possible_containers -> Map.put(graph, contained, [color | possible_containers])
      end
    end)
  end

  def stream_rules do
    Path.join(__DIR__, "input.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_rule/1)
  end

  def parse_rule(line) do
    [color, content_string] = String.split(line, " bags contain ")

    contents =
      case content_string do
        "no other bags." ->
          []

        _ ->
          content_string
          |> String.split(",")
          |> Enum.map(fn str -> String.trim(str, ".") end)
          |> Enum.map(fn str -> String.trim(str, "bag") end)
          |> Enum.map(fn str -> String.trim(str, "bags") end)
          |> Enum.map(&String.trim/1)
          |> Enum.map(&Integer.parse/1)
          |> Enum.map(fn {count, kind} -> {count, String.trim(kind)} end)
      end

    {color, contents}
  end
end
