defmodule Password do
  def problem_one do
    count_valid_passwords(&valid_on_policy_one?/1)
  end

  def problem_two do
    count_valid_passwords(&valid_on_policy_two?/1)
  end

  def count_valid_passwords(policy) do
    stream_passwords()
    |> Stream.filter(policy)
    |> Stream.scan(0, fn _valid_password, count -> count + 1 end)
    |> Enum.at(-1)
  end

  def valid_on_policy_one?([[min, max], target_char, password]) do
    char_count =
      password
      |> String.split("")
      |> Enum.filter(fn char -> char == target_char end)
      |> Enum.count()

    char_count >= min and char_count <= max
  end

  def valid_on_policy_two?([[first_position, second_position], target_char, password]) do
    char_1 = String.at(password, first_position - 1)

    char_2 = String.at(password, second_position - 1)

    (char_1 == target_char and char_2 != target_char) or
      (char_1 != target_char and char_2 == target_char)
  end

  def stream_passwords do
    Path.join(__DIR__, "input.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&process_password_string/1)
  end

  def process_password_string(line) do
    [num_string, char_string, password] = String.split(line, " ")

    valid_range =
      num_string
      |> String.split("-")
      |> Enum.map(fn str -> String.to_integer(str, 10) end)

    target_char =
      char_string
      |> String.split(":")
      |> Enum.at(0)

    [valid_range, target_char, password]
  end
end
