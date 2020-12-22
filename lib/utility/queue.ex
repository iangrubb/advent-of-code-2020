defmodule Queue do
  def create(), do: %{front: [], back: [], count: 0}

  def add(%{front: [], count: count} = queue, element) do
    queue
    |> Map.put(:front, [element])
    |> Map.put(:count, count + 1)
  end

  def add(%{back: back, count: count} = queue, element) do
    queue
    |> Map.put(:back, [element | back])
    |> Map.put(:count, count + 1)
  end

  def remove!(%{front: []}) do
    throw("Cannot remove from empty queue")
  end

  def remove!(%{front: [_first | []], back: back, count: count}) do
    %{front: Enum.reverse(back), back: [], count: count - 1}
  end

  def remove!(%{front: [_first | remainder], count: count} = queue) do
    queue
    |> Map.put(:front, remainder)
    |> Map.put(:count, count - 1)
  end

  def first(%{front: []}), do: nil

  def first(%{front: [first | _remainder]}), do: first

  def to_list(%{front: front, back: back}) do
    front ++ Enum.reverse(back)
  end
end
