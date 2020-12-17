defmodule Cube do
  def problem_one do
    initial_state(3)
    |> advance_world(6)
    |> Map.keys()
    |> Enum.count()
  end

  def problem_two do
    initial_state(4)
    |> advance_world(6)
    |> Map.keys()
    |> Enum.count()
  end

  def advance_world(world_state, step_count) do
    new_world =
      world_state
      |> Map.keys()
      |> Enum.reduce(%{}, fn active_coordinate, neighboor_counter ->
        active_coordinate
        |> neighboor_coordinates()
        |> Enum.reduce(neighboor_counter, fn neighboor_coordinate, neighboor_counter ->
          case Map.get(neighboor_counter, neighboor_coordinate) do
            nil -> Map.put(neighboor_counter, neighboor_coordinate, 1)
            val -> Map.put(neighboor_counter, neighboor_coordinate, val + 1)
          end
        end)
      end)
      |> Map.to_list()
      |> Enum.reduce(%{}, fn {coordinate, neighboor_count}, new_world ->
        cond do
          neighboor_count === 3 ->
            Map.put(new_world, coordinate, true)

          neighboor_count === 2 and Map.get(world_state, coordinate) ->
            Map.put(new_world, coordinate, true)

          true ->
            new_world
        end
      end)

    case step_count === 1 do
      true -> new_world
      false -> advance_world(new_world, step_count - 1)
    end
  end

  def neighboor_coordinates(target_coordinate) do
    options = [-1, 0, 1]

    baseline =
      target_coordinate
      |> Enum.count()
      |> get_baseline([])

    baseline
    |> Enum.with_index()
    |> Enum.reduce([baseline], fn {0, idx}, directions ->
      Enum.flat_map(directions, fn direction ->
        Enum.map(options, fn option ->
          List.update_at(direction, idx, fn _current -> option end)
        end)
      end)
    end)
    |> Enum.filter(fn coordinate -> coordinate !== baseline end)
    |> Enum.map(fn direction ->
      target_coordinate
      |> Enum.zip(direction)
      |> Enum.map(fn {coordinate, change} -> coordinate + change end)
    end)
  end

  def get_baseline(0, current), do: current

  def get_baseline(remaining, current), do: get_baseline(remaining - 1, [0 | current])

  def initial_state(dimensions) do
    "..#..#..
        #.#...#.
        ..#.....
        ##....##
        #..#.###
        .#..#...
        ###..#..
        ....#..#"
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row_chars, row_num}, state ->
      row_chars
      |> String.split("")
      |> Enum.filter(fn str -> str != "" end)
      |> Enum.with_index()
      |> Enum.reduce(state, fn
        {"#", col_num}, state ->
          Map.put(state, extend_for_dimension([row_num, col_num], dimensions), true)

        {".", _}, state ->
          state
      end)
    end)
  end

  def extend_for_dimension(vector, dimensions) when dimensions > 2,
    do: extend_for_dimension([0 | vector], dimensions - 1)

  def extend_for_dimension(vector, dimensions), do: vector
end
