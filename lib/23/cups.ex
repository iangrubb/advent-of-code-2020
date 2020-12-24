defmodule Cups do
  def problem_one do
    {finish, [1 | start]} =
      Enum.reduce(0..99, small_game_start(), fn _turn, game -> process_turn(game) end)
      |> game_to_list
      |> Enum.split_while(fn n -> n != 1 end)

    start
    |> Enum.concat(finish)
    |> Enum.join("")
  end

  def problem_two do
    %{cups: cups} =
      Enum.reduce(1..10_000_000, big_game_start(), fn _turn, game -> process_turn(game) end)

    Map.get(cups, 1) * Map.get(cups, Map.get(cups, 1))
  end

  def small_game_start() do
    [1, 5, 7, 6, 2, 3, 9, 8, 4]
    |> initialize_game_map()
  end

  def big_game_start do
    ([1, 5, 7, 6, 2, 3, 9, 8, 4] ++ Enum.reduce(1_000_000..10, [], fn n, list -> [n | list] end))
    |> initialize_game_map()
  end

  def game_to_list(%{cups: cups, current: current} = game) do
    game_to_list(game, [Map.get(cups, current), current])
  end

  def game_to_list(%{cups: cups, current: current} = game, [previous | _] = list) do
    case previous == current do
      true -> Enum.reverse(list)
      false -> game_to_list(game, [Map.get(cups, previous) | list])
    end
  end

  def initialize_game_map([first | _rem] = nums) do
    {cups, _} =
      (nums ++ Enum.take(nums, 1))
      |> Enum.reduce(nil, fn
        first, nil -> {%{}, first}
        next, {map, curr} -> {Map.put(map, curr, next), next}
      end)

    %{cups: cups, current: first, max: Enum.max(Map.keys(cups))}
  end

  def process_turn(%{cups: cups, current: current, max: max} = game) do
    first_removed = Map.get(cups, current)
    second_removed = Map.get(cups, first_removed)
    last_removed = Map.get(cups, second_removed)
    next_start = Map.get(cups, last_removed)

    destination_cup =
      get_destination_cup(current, [first_removed, second_removed, last_removed], max)

    next_after_destination = Map.get(cups, destination_cup)

    switched_cups =
      cups
      |> Map.put(current, next_start)
      |> Map.put(destination_cup, first_removed)
      |> Map.put(last_removed, next_after_destination)

    %{game | cups: switched_cups, current: next_start}
  end

  def get_destination_cup(id, exclusions, max) do
    next_id = if id == 1, do: max, else: id - 1

    case Enum.find(exclusions, fn ex -> ex == next_id end) do
      nil -> next_id
      _ -> get_destination_cup(next_id, exclusions, max)
    end
  end
end
