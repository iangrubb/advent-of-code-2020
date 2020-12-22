defmodule Combat do
  def problem_one do
    initialize_game(deck_one(), deck_two())
    |> run_game()
    |> Map.get(:player_one)
    |> Queue.to_list()
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {card, idx}, acc -> acc + card * (idx + 1) end)
  end

  def problem_two do
    initialize_game(deck_one(), deck_two())
    |> run_recursive_game()
    |> Map.get(:player_one)
    |> Queue.to_list()
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {card, idx}, acc -> acc + card * (idx + 1) end)
  end

  def run_game(%{player_one: player_one, player_two: player_two} = game) do
    case {Queue.first(player_one), Queue.first(player_two)} do
      {nil, _} ->
        game

      {_, nil} ->
        game

      {card_one, card_two} ->
        updated_game =
          cond do
            card_one > card_two ->
              player_one_update =
                player_one
                |> Queue.remove!()
                |> Queue.add(card_one)
                |> Queue.add(card_two)

              %{player_one: player_one_update, player_two: Queue.remove!(player_two)}

            card_two > card_one ->
              player_two_update =
                player_two
                |> Queue.remove!()
                |> Queue.add(card_two)
                |> Queue.add(card_one)

              %{player_one: Queue.remove!(player_one), player_two: player_two_update}
          end

        run_game(updated_game)
    end
  end

  def serialize_player(player) do
    player
    |> Queue.to_list()
    |> Enum.join("")
  end

  def run_recursive_game(
        %{player_one: player_one, player_two: player_two} = game,
        game_record \\ %{}
      ) do
    serialized_state = {serialize_player(player_one), serialize_player(player_two)}

    case Map.get(game_record, serialized_state) do
      nil ->
        updated_game_record = Map.put(game_record, serialized_state, true)

        player_one_card = Queue.first(player_one)

        player_two_card = Queue.first(player_two)

        winning_player =
          cond do
            player_one_card < player_one.count and player_two_card < player_two.count ->
              sub_game_deck_one =
                player_one
                |> Queue.remove!()
                |> Queue.to_list()
                |> Enum.take(player_one_card)

              sub_game_deck_two =
                player_two
                |> Queue.remove!()
                |> Queue.to_list()
                |> Enum.take(player_two_card)

              %{winner: sub_game_winner} =
                initialize_game(sub_game_deck_one, sub_game_deck_two)
                |> run_recursive_game()

              sub_game_winner

            true ->
              if player_one_card > player_two_card, do: 1, else: 2
          end

        case winning_player do
          1 ->
            updated_player_one =
              player_one
              |> Queue.remove!()
              |> Queue.add(player_one_card)
              |> Queue.add(player_two_card)

            updated_player_two = Queue.remove!(player_two)

            case updated_player_two.count do
              0 ->
                Map.put(
                  %{player_one: updated_player_one, player_two: updated_player_two},
                  :winner,
                  1
                )

              _ ->
                run_recursive_game(
                  %{player_one: updated_player_one, player_two: updated_player_two},
                  updated_game_record
                )
            end

          2 ->
            updated_player_two =
              player_two
              |> Queue.remove!()
              |> Queue.add(player_two_card)
              |> Queue.add(player_one_card)

            updated_player_one = Queue.remove!(player_one)

            case updated_player_one.count do
              0 ->
                Map.put(
                  %{player_one: updated_player_one, player_two: updated_player_two},
                  :winner,
                  2
                )

              _ ->
                run_recursive_game(
                  %{player_one: updated_player_one, player_two: updated_player_two},
                  updated_game_record
                )
            end
        end

      _ ->
        Map.put(game, :winner, 1)
    end
  end

  def deck_one() do
    [
      1,
      10,
      28,
      29,
      13,
      11,
      35,
      7,
      43,
      8,
      30,
      25,
      4,
      5,
      17,
      32,
      22,
      39,
      50,
      46,
      16,
      26,
      45,
      38,
      21
    ]
  end

  def deck_two() do
    [
      19,
      40,
      2,
      12,
      49,
      23,
      34,
      47,
      9,
      14,
      20,
      24,
      42,
      37,
      48,
      44,
      27,
      6,
      33,
      18,
      15,
      3,
      36,
      41,
      31
    ]
  end

  def initialize_game(cards_one, cards_two) do
    player_one_deck =
      cards_one
      |> Enum.reduce(Queue.create(), fn card, queue -> Queue.add(queue, card) end)

    player_two_deck =
      cards_two
      |> Enum.reduce(Queue.create(), fn card, queue -> Queue.add(queue, card) end)

    %{player_one: player_one_deck, player_two: player_two_deck}
  end
end
