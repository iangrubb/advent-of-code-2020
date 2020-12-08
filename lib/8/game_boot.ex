defmodule GameBoot do
  def problem_one do
    {:repeat, acc, _visited} =
      generate_step_map()
      |> search_for_halt()

    acc
  end

  def problem_two do
    generate_step_map()
    |> search_for_fix()
  end

  def search_for_fix({concluding_index, step_map}) do
    search_for_fix_rec(step_map, {0, 0}, %{}, concluding_index)
  end

  def search_for_fix_rec(step_map, {idx, acc} = program_state, visited, concluding_index) do
    new_visited = Map.put(visited, idx, true)

    case Map.get(step_map, idx) do
      {"acc", value} ->
        search_for_fix_rec(step_map, {idx + 1, acc + value}, new_visited, concluding_index)

      {rule, steps} ->
        jump =
          case rule do
            "jmp" -> 1
            "nop" -> steps
          end

        case search_for_halt_rec(step_map, {idx + jump, acc}, new_visited, concluding_index) do
          {:conclude, acc, _visited} ->
            acc

          {:repeat, _acc, possible_visited} ->
            new_state = advance(step_map, program_state)
            search_for_fix_rec(step_map, new_state, possible_visited, concluding_index)
        end
    end
  end

  def search_for_halt({concluding_index, step_map}) do
    search_for_halt_rec(step_map, {0, 0}, %{}, concluding_index)
  end

  def search_for_halt_rec(step_map, {idx, acc} = program_state, visited, concluding_index) do
    case {idx, Map.get(visited, idx)} do
      {^concluding_index, _} ->
        {:conclude, acc, visited}

      {_, true} ->
        {:repeat, acc, visited}

      {_, _} ->
        new_state = advance(step_map, program_state)
        search_for_halt_rec(step_map, new_state, Map.put(visited, idx, true), concluding_index)
    end
  end

  def advance(step_map, {idx, acc}) do
    case Map.get(step_map, idx) do
      {"acc", value} -> {idx + 1, acc + value}
      {"jmp", steps} -> {idx + steps, acc}
      {"nop", _} -> {idx + 1, acc}
    end
  end

  def generate_step_map do
    stream_steps()
    |> Stream.map(fn step ->
      [rule, num_string] = String.split(step, " ")
      {rule, String.to_integer(num_string)}
    end)
    |> Stream.scan({0, %{}}, fn step, {idx, map} ->
      {idx + 1, Map.put(map, idx, step)}
    end)
    |> Enum.at(-1)
  end

  def stream_steps do
    Path.join(__DIR__, "input.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end
end
