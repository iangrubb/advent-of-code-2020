defmodule Seats do
  def problem_one do
    seating_grid()
    |> update_while_unstable()
    |> Enum.reduce(0, fn row, acc ->
      acc +
        Enum.reduce(row, 0, fn
          "#", acc -> acc + 1
          _char, acc -> acc
        end)
    end)
  end

  def problem_two do
    build_seating_map()
    |> update_map_until_stable()
    |> Map.values()
    |> Enum.filter(fn node -> node.space == "#" end)
    |> Enum.count()
  end

  def build_seating_map do
    seating_grid()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, row_idx}, map ->
      row
      |> Enum.with_index()
      |> Enum.reduce(map, fn {space, col_idx}, map ->
        location = {col_idx, row_idx}

        neighboors =
          case space do
            "." ->
              []

            _ ->
              [{-1, 0}, {-1, -1}, {0, -1}, {1, -1}]
              |> Enum.map(fn direction -> search_for_target(map, direction, location) end)
              |> Enum.filter(fn target -> target != nil end)
          end

        neighboors
        |> Enum.reduce(map, fn target, map ->
          neighboor = Map.get(map, target)
          Map.put(map, target, %{neighboor | neighboors: [location | neighboor.neighboors]})
        end)
        |> Map.put(location, %{
          space: space,
          neighboors: neighboors
        })
      end)
    end)
  end

  def update_map_until_stable(map) do
    update =
      map
      |> Map.keys()
      |> Enum.reduce(%{}, fn key, updated_map ->
        Map.put(updated_map, key, %{
          space: update_space(map, key),
          neighboors: Map.get(map, key).neighboors
        })
      end)

    case map == update do
      true -> update
      false -> update_map_until_stable(update)
    end
  end

  def update_space(map, key) do
    target = Map.get(map, key)

    occupancy =
      target.neighboors
      |> Enum.map(fn neighboor -> Map.get(map, neighboor).space end)
      |> Enum.filter(fn space -> space == "#" end)
      |> Enum.count()

    cond do
      target.space == "L" && occupancy == 0 -> "#"
      target.space == "#" && occupancy >= 5 -> "L"
      true -> target.space
    end
  end

  def search_for_target(map, {x_change, y_change} = direction, {x, y}) do
    target = {x + x_change, y + y_change}

    case Map.get(map, target) do
      nil ->
        nil

      neighboor ->
        case neighboor.space do
          "." -> search_for_target(map, direction, target)
          _ -> target
        end
    end
  end

  def update_while_unstable(grid) do
    {new_grid, changed?} = update_grid(grid)

    case changed? do
      false -> new_grid
      true -> update_while_unstable(new_grid)
    end
  end

  def update_grid(grid) do
    {new_grid, changed?} =
      grid
      |> row_data()
      |> Enum.map(fn rows ->
        rows
        |> Enum.map(fn
          nil -> nil
          row -> ListZipper.create(row)
        end)
        |> update_row([], false)
      end)
      |> Enum.reduce({[], false}, fn {row, changed?}, {rows, previous_change?} ->
        {[row | rows], previous_change? or changed?}
      end)

    {Enum.reverse(new_grid), changed?}
  end

  def update_row([_prev, current, _next] = zippers, row, changed?) do
    occupancy =
      Enum.reduce(zippers, 0, fn
        nil, acc ->
          acc

        zipper, acc ->
          row_count =
            zipper
            |> ListZipper.window()
            |> Enum.filter(fn el -> el == "#" end)
            |> Enum.count()

          acc + row_count
      end)

    point =
      cond do
        current.current == "L" && occupancy == 0 -> "#"
        current.current == "#" && occupancy >= 5 -> "L"
        true -> current.current
      end

    point_changed? = current.current != point

    case current.remaining do
      [] ->
        {Enum.reverse([point | row]), changed? or point_changed?}

      _ ->
        zippers
        |> Enum.map(fn zipper ->
          case zipper do
            nil -> nil
            _ -> ListZipper.forward(zipper)
          end
        end)
        |> update_row([point | row], changed? or point_changed?)
    end
  end

  def row_data(grid) do
    grid
    |> ListZipper.create()
    |> ListZipper.reduce([], fn zipper, prior -> [ListZipper.window(zipper) | prior] end)
    |> Enum.reverse()
  end

  def seating_grid do
    Path.join(__DIR__, "input.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Enum.to_list()
  end
end
