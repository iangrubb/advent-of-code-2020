defmodule Memory do
  def problem_one do
    input()
    |> start_game()
    |> advance_to_turn(2020)
  end

  def problem_two do
    input()
    |> start_game()
    |> advance_to_turn(30_000_000)
  end

  def advance_to_turn(%{last_turn: last_turn} = game_state, turn) do
    case last_turn === turn do
      true ->
        game_state

      false ->
        game_state
        |> advance()
        |> advance_to_turn(turn)
    end
  end

  def advance(game_state) do
    game_state
    |> update_history()
    |> update_move(determine_next(game_state))
  end

  def start_game(initial_moves) do
    initial_moves
    |> Enum.reduce(nil, fn
      move, nil ->
        %{history: %{}, last_spoken: move, last_turn: 1}

      move, game_state ->
        game_state
        |> update_history()
        |> update_move(move)
    end)
  end

  def determine_next(%{history: history, last_spoken: last_spoken, last_turn: last_turn}) do
    case Map.get(history, last_spoken) do
      nil -> 0
      turn -> last_turn - turn
    end
  end

  def update_history(
        %{history: history, last_spoken: last_spoken, last_turn: last_turn} = game_state
      ) do
    %{game_state | history: Map.put(history, last_spoken, last_turn)}
  end

  def update_move(%{last_turn: last_turn} = game_state, new_move) do
    %{game_state | last_spoken: new_move, last_turn: last_turn + 1}
  end

  def input do
    [15, 12, 0, 14, 3, 1]
  end
end
