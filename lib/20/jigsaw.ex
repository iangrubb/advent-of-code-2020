defmodule Jigsaw do
  def problem_one do
    get_tile_borders()
    |> build_connection_graph()
    |> Map.to_list()
    |> Enum.filter(fn {_, list} -> Enum.count(list) == 2 end)
    |> Enum.reduce(1, fn {id, _}, acc -> acc * String.to_integer(id) end)
  end

  def problem_two do
    tile_borders = get_tile_borders()

    tile_interiors = get_tile_interiors()

    connections =
      tile_borders
      |> build_connection_graph()

    corner_connections =
      connections
      |> Map.to_list()
      |> Enum.filter(fn {_id, list} -> Enum.count(list) == 2 end)

    map_images =
      corner_connections
      |> Enum.flat_map(fn {id, [{conn_1_id, conn_1_side, _, _}, {conn_2_id, conn_2_side, _, _}]} ->
        [
          initialize_image(id, conn_1_id, conn_1_side, conn_2_id, conn_2_side),
          initialize_image(id, conn_2_id, conn_2_side, conn_1_id, conn_1_side)
        ]
      end)
      |> Enum.map(fn image_state -> construct_image(image_state, connections) end)
      |> Enum.map(fn image_region_map ->
        0..11
        |> Enum.flat_map(fn row_idx ->
          0..11
          |> Enum.reduce(nil, fn
            col_idx, nil ->
              %{id: id, flipped: flipped, rotation: rotation} =
                Map.get(image_region_map, {col_idx, row_idx})

              tile_interiors
              |> Map.get(id)
              |> transform_region(flipped, rotation)

            col_idx, rows ->
              %{id: id, flipped: flipped, rotation: rotation} =
                Map.get(image_region_map, {col_idx, row_idx})

              tile_interiors
              |> Map.get(id)
              |> transform_region(flipped, rotation)
              |> Enum.zip(rows)
              |> Enum.map(fn {addition, previous} -> previous <> addition end)
          end)
        end)
      end)

    valid_map =
      map_images
      |> Enum.find(fn image ->
        count =
          image
          |> detect_monsters()
          |> Enum.count()

        count > 0
      end)

    valid_map
    |> detect_monsters()
    |> Enum.reduce(valid_map, fn monster_location, image ->
      remove_monster(image, monster_location)
    end)
    |> Enum.map(fn row ->
      row
      |> String.codepoints()
      |> Enum.filter(fn char -> char == "#" end)
      |> Enum.count()
    end)
    |> Enum.reduce(0, fn count, acc -> count + acc end)
  end

  def detect_monsters(image) do
    image
    |> Enum.map(fn row ->
      {
        monster_top_starts(row),
        monster_middle_starts(row),
        monster_bottom_starts(row)
      }
    end)
    |> Enum.with_index()
    |> Enum.reduce({[], [], []}, fn
      {{top_starts, middle_starts, bottom_starts}, y_idx},
      {previous_top, previous_middle, previous_confirmed} ->
        new_middle =
          Enum.filter(previous_top, fn top_start ->
            Enum.find(middle_starts, fn mid_start -> top_start == mid_start end)
          end)

        new_confirmed =
          previous_middle
          |> Enum.filter(fn mid_start ->
            Enum.find(bottom_starts, fn bot_start -> mid_start == bot_start end)
          end)
          |> Enum.map(fn x_idx -> {x_idx, y_idx - 2} end)

        {top_starts, new_middle, new_confirmed ++ previous_confirmed}
    end)
    |> List.wrap()
    |> Enum.map(fn {_, _, monster_coordinates} -> monster_coordinates end)
    |> Enum.at(0)
  end

  def scan_for_target(row, target) do
    length = String.length(row) - 1

    0..length
    |> Enum.reduce([], fn idx, starts ->
      slice = String.slice(row, idx, 20)

      check =
        Enum.all?(target, fn target_idx ->
          String.at(slice, target_idx) == "#"
        end)

      case check do
        true -> [idx | starts]
        false -> starts
      end
    end)
  end

  def monster_top_starts(row) do
    scan_for_target(row, [18])
  end

  def monster_middle_starts(row) do
    scan_for_target(row, [0, 5, 6, 11, 12, 17, 18, 19])
  end

  def monster_bottom_starts(row) do
    scan_for_target(row, [1, 4, 7, 10, 13, 16])
  end

  def remove_monster(image, {x, y}) do
    image
    |> Enum.with_index()
    |> Enum.map(fn {row, idx} ->
      cond do
        idx == y ->
          {start, remainder} = String.split_at(row, x + 18)
          start <> "." <> String.slice(remainder, 1, String.length(remainder))

        idx == y + 1 ->
          [0, 5, 6, 11, 12, 17, 18, 19]
          |> Enum.reduce(row, fn x_offset, row ->
            {start, remainder} = String.split_at(row, x + x_offset)
            change = start <> "." <> String.slice(remainder, 1, String.length(remainder))
          end)

        idx == y + 2 ->
          [1, 4, 7, 10, 13, 16]
          |> Enum.reduce(row, fn x_offset, row ->
            {start, remainder} = String.split_at(row, x + x_offset)
            start <> "." <> String.slice(remainder, 1, String.length(remainder))
          end)

        true ->
          row
      end
    end)
  end

  def transform_region(region, flipped?, rotation) do
    rotated =
      0..rotation
      |> Enum.reduce(region, fn
        0, region -> region
        _, region -> rotate_region(region)
      end)

    case flipped? do
      true -> Enum.reverse(rotated)
      false -> rotated
    end
  end

  def rotate_region(region) do
    old_rows = Enum.reverse(region)

    0..(Enum.count(region) - 1)
    |> Enum.reduce([], fn
      idx, new_rows ->
        new_row = Enum.map(old_rows, fn row -> String.slice(row, idx, 1) end)
        [new_row | new_rows]
    end)
    |> Enum.reverse()
    |> Enum.map(fn chars -> Enum.join(chars) end)
  end

  def initialize_image(origin_id, right_id, right_connection, bottom_id, bottom_connection) do
    rotation = get_rotation_distance(right_connection, :right)

    flipped = apply_rotation(rotation, bottom_connection) == :top

    {
      Map.put(%{}, {0, 0}, %{id: origin_id, flipped: flipped, rotation: rotation}),
      Map.put(%{}, origin_id, {0, 0}),
      [
        {right_id, :right, origin_id},
        {bottom_id, :bottom, origin_id}
      ]
    }
  end

  def construct_image({image_map, _coordinate_lookup_map, []}, _connections), do: image_map

  def construct_image(
        {image_map, coordinate_lookup_map,
         [{addition_id, prior_direction, prior_id} | remaining_additions]},
        connections
      ) do
    case Map.get(coordinate_lookup_map, addition_id) do
      nil ->
        {_, attach_side, inversion, _} =
          connections
          |> Map.get(addition_id)
          |> Enum.find(fn {id, _, _, _} -> id === prior_id end)

        {prior_x, prior_y} = prior_coordinate = Map.get(coordinate_lookup_map, prior_id)

        %{flipped: prior_flipped} = Map.get(image_map, prior_coordinate)

        flipped = if inversion == :invert, do: not prior_flipped, else: prior_flipped

        coordinate =
          case prior_direction do
            :right -> {prior_x + 1, prior_y}
            :bottom -> {prior_x, prior_y + 1}
          end

        rotation_target =
          case {prior_direction, flipped} do
            {:right, _} -> :left
            {:bottom, true} -> :bottom
            {:bottom, false} -> :top
          end

        rotation = get_rotation_distance(attach_side, rotation_target)

        new_additions =
          connections
          |> Map.get(addition_id)
          |> Enum.map(fn {id, side, _, _} ->
            adjusted_direction =
              case {apply_rotation(rotation, side), flipped} do
                {:left, _} -> :left
                {:right, _} -> :right
                {:top, true} -> :bottom
                {:top, false} -> :top
                {:bottom, true} -> :top
                {:bottom, false} -> :bottom
              end

            {id, adjusted_direction, addition_id}
          end)
          |> Enum.filter(fn {_, dir, _} -> dir == :bottom or dir == :right end)

        construct_image(
          {
            Map.put(image_map, coordinate, %{
              id: addition_id,
              flipped: flipped,
              rotation: rotation
            }),
            Map.put(coordinate_lookup_map, addition_id, coordinate),
            new_additions ++ remaining_additions
          },
          connections
        )

      _ ->
        construct_image({image_map, coordinate_lookup_map, remaining_additions}, connections)
    end
  end

  def get_rotation_distance(from, to) do
    [:left, :top, :right, :bottom, :left, :top, :right]
    |> Enum.drop_while(fn dir -> dir != from end)
    |> Enum.take_while(fn dir -> dir != to end)
    |> Enum.count()
  end

  def apply_rotation(distance, from) do
    [:left, :top, :right, :bottom, :left, :top, :right]
    |> Enum.drop_while(fn dir -> dir != from end)
    |> Enum.at(distance)
  end

  def build_connection_graph(tile_border_map) do
    tile_border_map
    |> build_edge_map()
    |> Map.to_list()
    |> Enum.filter(fn {_pattern, list} -> Enum.count(list) == 2 end)
    |> Enum.reduce(%{}, fn {_pattern, [{id_1, side_1, flip_1}, {id_2, side_2, flip_2}]},
                           connection_graph ->
      inversion = if flip_1 != flip_2, do: :fit, else: :invert

      connection_graph
      |> Map.put(
        id_1,
        Enum.uniq([{id_2, side_1, inversion, side_2} | Map.get(connection_graph, id_1, [])])
      )
      |> Map.put(
        id_2,
        Enum.uniq([{id_1, side_2, inversion, side_1} | Map.get(connection_graph, id_2, [])])
      )
    end)
  end

  def build_edge_map(tile_data) do
    tile_data
    |> Map.to_list()
    |> Enum.reduce(%{}, fn {id, tile_datum}, edge_map ->
      tile_datum
      |> Map.to_list()
      |> Enum.reduce(edge_map, fn {direction, pattern}, edge_map ->
        edge_map
        |> set_edge_data(pattern, id, direction, :normal)
        |> set_edge_data(pattern, id, direction, :flip)
      end)
    end)
  end

  def set_edge_data(edge_map, pattern, id, direction, flip) do
    key = if flip == :normal, do: pattern, else: String.reverse(pattern)

    Map.put(edge_map, key, [{id, direction, flip} | Map.get(edge_map, key, [])])
  end

  def get_tile_borders do
    Path.join(__DIR__, "input.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.scan(%{}, fn
      line, %{} = map ->
        {map, extract_id(line)}

      line, {map, id} ->
        {map, id, %{top: line, left: "", right: ""} |> update_current(line)}

      "", {map, id, current} ->
        adjusted_current =
          current
          |> Map.put(:bottom, String.reverse(current.bottom))
          |> Map.put(:left, String.reverse(current.left))

        Map.put(map, id, adjusted_current)

      line, {map, id, current} ->
        {map, id, update_current(current, line)}
    end)
    |> Enum.at(-1)
  end

  def get_tile_interiors do
    Path.join(__DIR__, "input.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.scan(%{}, fn
      line, %{} = map ->
        {map, extract_id(line), :discard}

      _line, {map, id, :discard} ->
        {map, id, :start}

      line, {map, id, :start} ->
        {map, id, [], line}

      "", {map, id, rows, _} ->
        Map.put(map, id, Enum.reverse(rows))

      line, {map, id, rows, previous_line} ->
        {map, id, [String.slice(previous_line, 1, String.length(previous_line) - 2) | rows], line}
    end)
    |> Enum.at(-1)
  end

  def update_current(current, line) do
    current
    |> Map.put(:bottom, line)
    |> Map.put(:left, Map.get(current, :left) <> String.slice(line, 0, 1))
    |> Map.put(:right, Map.get(current, :right) <> String.last(line))
  end

  def extract_id(line) do
    line
    |> String.split(" ")
    |> Enum.at(1)
    |> String.split(":")
    |> Enum.at(0)
  end
end
