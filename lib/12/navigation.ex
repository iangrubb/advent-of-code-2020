defmodule Navigation do
  def problem_one do
    %{x: x, y: y} =
      stream_instructions()
      |> Stream.scan(initial_location(), fn instruction, location ->
        update_location(location, instruction)
      end)
      |> Enum.at(-1)

    abs(x) + abs(y)
  end

  def initial_location(), do: %{x: 0, y: 0, direction: 0}

  def convert_degrees(degrees) do
    case rem(degrees, 360) do
      0 -> "E"
      90 -> "N"
      180 -> "W"
      270 -> "S"
      -90 -> "S"
      -180 -> "W"
      -270 -> "N"
    end
  end

  def update_location(%{x: x, y: y, direction: direction} = location, instruction) do
    case instruction do
      {"N", distance} -> %{location | y: y + distance}
      {"S", distance} -> %{location | y: y - distance}
      {"E", distance} -> %{location | x: x + distance}
      {"W", distance} -> %{location | x: x - distance}
      {"F", distance} -> update_location(location, {convert_degrees(direction), distance})
      {"L", angle} -> %{location | direction: direction + angle}
      {"R", angle} -> %{location | direction: direction - angle}
    end
  end

  def problem_two do
    %{x: x, y: y} =
      stream_instructions()
      |> Stream.scan(initial_location_two(), fn instruction, location ->
        update_location_two(location, instruction)
      end)
      |> Enum.at(-1)

    abs(x) + abs(y)
  end

  def initial_location_two(), do: %{x: 0, y: 0, wayX: 10, wayY: 1}

  def update_location_two(%{x: x, y: y, wayX: wayX, wayY: wayY} = location, instruction) do
    case instruction do
      {"N", distance} -> %{location | wayY: wayY + distance}
      {"S", distance} -> %{location | wayY: wayY - distance}
      {"E", distance} -> %{location | wayX: wayX + distance}
      {"W", distance} -> %{location | wayX: wayX - distance}
      {"F", distance} -> %{location | x: x + wayX * distance, y: y + wayY * distance}
      {"L", angle} -> rotate_waypoint(location, angle)
      {"R", angle} -> rotate_waypoint(location, -angle)
    end
  end

  def rotate_waypoint(%{wayX: wayX, wayY: wayY} = location, angle) do
    case convert_degrees(angle) do
      "E" -> location
      "N" -> %{location | wayX: -wayY, wayY: wayX}
      "W" -> %{location | wayX: -wayX, wayY: -wayY}
      "S" -> %{location | wayX: wayY, wayY: -wayX}
    end
  end

  def stream_instructions do
    Path.join(__DIR__, "input.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn str -> String.split_at(str, 1) end)
    |> Stream.map(fn {command, numString} -> {command, String.to_integer(numString)} end)
  end
end
