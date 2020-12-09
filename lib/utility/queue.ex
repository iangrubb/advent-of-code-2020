defmodule Queue do
  def create(), do: %{front: [], back: []}

  def add(%{front: []} = queue, element) do
    queue
    |> Map.put(:front, [element])
  end

  def add(%{back: back} = queue, element) do
    queue
    |> Map.put(:back, [element | back])
  end

  def remove!(%{front: []}) do
    throw("Cannot remove from empty queue")
  end

  def remove!(%{front: [_first | []], back: back}) do
    %{front: Enum.reverse(back), back: []}
  end

  def remove!(%{front: [_first | remainder]} = queue) do
    Map.put(queue, :front, remainder)
  end

  def first(%{front: []}), do: nil

  def first(%{front: [first | _remainder]}), do: first

  def to_list(%{front: front, back: back}) do
    front ++ Enum.reverse(back)
  end
end
