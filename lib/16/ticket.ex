defmodule Ticket do
  def problem_one do
    stream_tickets()
    |> Stream.scan(0, fn ticket, error_sum ->
      ticket
      |> Enum.reduce(error_sum, fn field_value, error_sum ->
        range_for_value =
          rules()
          |> Enum.flat_map(fn %{ranges: ranges} -> ranges end)
          |> Enum.find(fn [low, high] -> field_value >= low and field_value <= high end)

        case range_for_value do
          nil -> error_sum + field_value
          _ -> error_sum
        end
      end)
    end)
    |> Enum.at(-1)
  end

  def problem_two do
    stream_tickets()
    |> Stream.map(fn ticket ->
      ticket
      |> Enum.map(fn field_value ->
        rules()
        |> Enum.filter(fn %{ranges: ranges} ->
          !Enum.find(ranges, fn [low, high] -> field_value >= low and field_value <= high end)
        end)
        |> Enum.map(fn %{field: field} -> field end)
      end)
    end)
    |> Stream.filter(fn field_option_sets ->
      !Enum.find(field_option_sets, fn excluded_options -> excluded_options == fields() end)
    end)
    |> Stream.scan(fn new_exclusion_sets, existing_exclusion_sets ->
      Enum.zip(existing_exclusion_sets, new_exclusion_sets)
      |> Enum.map(fn {existing_exclusions, new_exclusions} ->
        existing_exclusions
        |> Enum.concat(new_exclusions)
        |> Enum.uniq()
      end)
    end)
    |> Enum.at(-1)
    |> Enum.map(fn exclusions ->
      rules()
      |> Enum.map(fn %{field: field} -> field end)
      |> Enum.filter(fn field -> !Enum.find(exclusions, fn ex -> ex == field end) end)
    end)
    |> condense_options()
    |> Enum.zip(your_ticket())
    |> Enum.filter(fn {[field], _} -> String.starts_with?(field, "departure") end)
    |> Enum.reduce(1, fn {_, val}, acc -> acc * val end)
  end

  def condense_options(option_sets, locked \\ []) do
    target =
      option_sets
      |> Enum.frequencies()
      |> Map.to_list()
      |> Enum.find(fn {options, frequency} ->
        !Enum.find(locked, fn lock -> lock === options end) and Enum.count(options) === frequency
      end)

    case target do
      nil ->
        option_sets

      {cluster, _} ->
        option_sets
        |> Enum.map(fn options ->
          case options == cluster do
            true ->
              options

            false ->
              Enum.filter(options, fn opt -> !Enum.find(cluster, fn cl -> cl == opt end) end)
          end
        end)
        |> condense_options([cluster | locked])
    end
  end

  def your_ticket do
    [83, 137, 101, 73, 67, 61, 103, 131, 151, 127, 113, 107, 109, 89, 71, 139, 167, 97, 59, 53]
  end

  def fields do
    rules()
    |> Enum.map(fn %{field: field} -> field end)
  end

  def rules do
    raw_rules()
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn str ->
      [field, rangesStr] = String.split(str, ": ")

      ranges =
        rangesStr
        |> String.split(" or ")
        |> Enum.map(fn str ->
          str
          |> String.split("-")
          |> Enum.map(&String.to_integer/1)
        end)

      %{field: field, ranges: ranges}
    end)
  end

  def raw_rules do
    "departure location: 47-874 or 885-960
        departure station: 25-616 or 622-964
        departure platform: 42-807 or 825-966
        departure track: 36-560 or 583-965
        departure date: 37-264 or 289-968
        departure time: 27-325 or 346-954
        arrival location: 37-384 or 391-950
        arrival station: 35-233 or 244-963
        arrival platform: 26-652 or 675-949
        arrival track: 41-689 or 710-954
        class: 27-75 or 81-952
        duration: 45-784 or 807-967
        price: 40-350 or 374-970
        route: 30-892 or 904-968
        row: 47-144 or 151-957
        seat: 28-750 or 773-973
        train: 30-456 or 475-950
        type: 34-642 or 648-968
        wagon: 42-486 or 498-970
        zone: 37-152 or 167-973"
  end

  def stream_tickets do
    Path.join(__DIR__, "input.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn str ->
      str
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
