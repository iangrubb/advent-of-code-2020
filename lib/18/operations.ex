defmodule Operations do
  def problem_one do
    stream_problems()
    |> Stream.map(fn problem -> compute(problem, [["+", "*"]]) end)
    |> Stream.scan(0, fn number, acc -> number + acc end)
    |> Enum.at(-1)
  end

  def problem_two do
    stream_problems()
    |> Stream.map(fn problem -> compute(problem, [["+"], ["*"]]) end)
    |> Stream.scan(0, fn number, acc -> number + acc end)
    |> Enum.at(-1)
  end

  def compute(problem, precedence) do
    {result, _remainder} = compute_segment(problem, precedence, nil)
    result
  end

  def compute_segment(problem, precedence, search_state) do
    case problem do
      ["(" | continuation] ->
        {result, [")" | remainder]} = compute_segment(continuation, precedence, nil)
        compute_segment([result | remainder], precedence, search_state)

      [number] ->
        {number, []}

      [number, char | continuation] ->
        case char in terminators(precedence, search_state) do
          true ->
            {number, [char | continuation]}

          false ->
            {result, remainder} = compute_segment(continuation, precedence, char)
            compute_segment([apply_opp(number, result, char) | remainder], precedence, nil)
        end
    end
  end

  def terminators(_precedence, nil), do: [")"]

  def terminators(precedence, opp) do
    precedence
    |> Enum.drop_while(fn precedence_level ->
      not Enum.any?(precedence_level, fn p -> p == opp end)
    end)
    |> List.flatten()
    |> Enum.concat([")"])
  end

  def apply_opp(num_1, num_2, "+"), do: num_1 + num_2

  def apply_opp(num_1, num_2, "*"), do: num_1 * num_2

  def stream_problems do
    special_characters = ["(", ")", "*", "+"]

    Path.join(__DIR__, "input.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn str ->
      str
      |> String.split("")
      |> Enum.filter(fn str -> str != "" and str != " " end)
      |> Enum.map(fn str ->
        case Enum.find(special_characters, fn sc -> sc == str end) do
          nil -> String.to_integer(str)
          _ -> str
        end
      end)
    end)
  end
end
