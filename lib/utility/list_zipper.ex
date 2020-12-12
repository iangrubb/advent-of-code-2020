defmodule ListZipper do
  def create(nil), do: nil

  def create([current | remaining]) do
    %{previous: [], current: current, remaining: remaining}
  end

  def forward(%{remaining: []} = zipper), do: zipper

  def forward(%{previous: previous, current: current, remaining: [next | remaining]}) do
    %{previous: [current | previous], current: next, remaining: remaining}
  end

  def back(%{previous: []} = zipper), do: zipper

  def back(%{previous: [next | previous], current: current, remaining: remaining}) do
    %{previous: previous, current: next, remaining: [current | remaining]}
  end

  def reduce(zipper, acc, callback) do
    new_acc = callback.(zipper, acc)

    case zipper.remaining do
      [] -> new_acc
      _ -> reduce(forward(zipper), new_acc, callback)
    end
  end

  def window(%{previous: previous, current: current, remaining: remaining}) do
    prior = if previous == [], do: nil, else: Enum.at(previous, 0)
    next = if remaining == [], do: nil, else: Enum.at(remaining, 0)
    [prior, current, next]
  end
end
