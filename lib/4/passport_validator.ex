defmodule PassportValidator do
  def problem_one do
    count_valid_passport_submissions(&valid_fields?/1)
  end

  def problem_two do
    count_valid_passport_submissions(&valid_passport?/1)
  end

  def count_valid_passport_submissions(condition) do
    stream_passport_submissions()
    |> Stream.map(&convert_submission_to_passport/1)
    |> Stream.filter(condition)
    |> Stream.scan(0, fn _passport, count -> count + 1 end)
    |> Enum.at(-1)
  end

  defp convert_submission_to_passport(submission) do
    submission
    |> Enum.map(fn sub -> String.split(sub, ":") end)
    |> Enum.reduce(%{}, fn [key, value], passport ->
      Map.put(passport, key, convert_value(key, value))
    end)
  end

  defp convert_value(key, value) do
    case key do
      "byr" -> String.to_integer(value)
      "iyr" -> String.to_integer(value)
      "eyr" -> String.to_integer(value)
      "hgt" -> Integer.parse(value)
      _ -> value
    end
  end

  defp valid_passport?(passport) do
    [
      &valid_fields?/1,
      fn passport -> value_at_key_in_range?(passport, "byr", 1920, 2002) end,
      fn passport -> value_at_key_in_range?(passport, "iyr", 2010, 2020) end,
      fn passport -> value_at_key_in_range?(passport, "eyr", 2020, 2030) end,
      &valid_height?/1,
      &valid_hair_color?/1,
      &valid_eye_color?/1,
      &valid_passport_number/1
    ]
    |> Enum.all?(fn condition -> condition.(passport) end)
  end

  def value_at_key_in_range?(passport, key, min, max) do
    value = passport[key]
    value <= max and value >= min
  end

  def valid_height?(passport) do
    case passport["hgt"] do
      {value, "in"} -> value >= 59 and value <= 76
      {value, "cm"} -> value >= 150 and value <= 193
      _ -> false
    end
  end

  def valid_hair_color?(passport) do
    String.match?(passport["hcl"], ~r/#[a-f0-9]{6}/) and String.length(passport["hcl"]) === 7
  end

  def valid_eye_color?(passport) do
    String.match?(passport["ecl"], ~r/amb|blu|brn|gry|grn|hzl|oth/)
  end

  def valid_passport_number(passport) do
    String.match?(passport["pid"], ~r/[0-9]{9}/) and String.length(passport["pid"]) === 9
  end

  def valid_fields?(passport) do
    ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]
    |> Enum.all?(fn key -> Map.has_key?(passport, key) end)
  end

  defp stream_passport_rows() do
    Path.join(__DIR__, "passports.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn row -> String.split(row, " ") end)
  end

  defp stream_passport_submissions() do
    stream_passport_rows()
    |> Stream.chunk_while(
      [],
      fn row, subs ->
        case row do
          [""] -> {:cont, subs, []}
          _ -> {:cont, row ++ subs}
        end
      end,
      fn subs -> {:cont, subs, []} end
    )
  end
end
