defmodule Docking do
  use Bitwise, only_operators: true

  def problem_one do
    {program_memory, _} =
      stream_instructions()
      |> Stream.scan({%{}, nil}, fn
        {:mask, mask}, {memory, _old_mask} ->
          {memory, mask}

        {:memory, key, value}, {memory, mask} ->
          masked_value =
            value
            |> apply_zeros(mask)
            |> apply_ones(mask)

          {Map.put(memory, key, masked_value), mask}
      end)
      |> Enum.at(-1)

    program_memory
    |> Map.values()
    |> Enum.reduce(0, fn num, acc -> num + acc end)
  end

  def apply_zeros(value, mask) do
    zero_mask =
      mask
      |> String.split("")
      |> Enum.filter(fn str -> str != "" end)
      |> Enum.map(fn
        "X" -> "1"
        num -> num
      end)
      |> Enum.map(&String.to_integer/1)
      |> Integer.undigits(2)

    value &&& zero_mask
  end

  def apply_ones(value, mask) do
    one_mask =
      mask
      |> String.split("")
      |> Enum.filter(fn str -> str != "" end)
      |> Enum.map(fn
        "X" -> "0"
        num -> num
      end)
      |> Enum.map(&String.to_integer/1)
      |> Integer.undigits(2)

    value ||| one_mask
  end

  def problem_two do
    {program_memory, _map} =
      stream_instructions()
      |> Stream.scan({%{}, nil}, fn
        {:mask, mask}, {memory, _old_mask} ->
          {memory, mask}

        {:memory, key, value}, {memory, mask} ->
          updated_memory =
            mask
            |> String.split("")
            |> Enum.filter(fn str -> str != "" end)
            |> Enum.with_index()
            |> Enum.reduce([key], fn
              {"X", idx}, addresses ->
                addresses
                |> Enum.flat_map(fn address -> address_options(address, idx) end)

              {"1", idx}, addresses ->
                addresses
                |> Enum.map(fn address ->
                  round(:math.pow(2, 35 - idx)) ||| address
                end)

              {"0", _idx}, addresses ->
                addresses
            end)
            |> Enum.reduce(memory, fn address, memory -> Map.put(memory, address, value) end)

          {updated_memory, mask}
      end)
      |> Enum.at(-1)

    program_memory
    |> Map.values()
    |> Enum.reduce(0, fn num, acc -> num + acc end)
  end

  def address_options(address, bit_idx) do
    mask = round(:math.pow(2, 35 - bit_idx))

    with_one = mask ||| address

    with_zero = mask ^^^ round(:math.pow(2, 36) - 1) &&& address

    [with_zero, with_one]
  end

  def stream_instructions do
    Path.join(__DIR__, "input.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn str -> String.split(str, " = ") end)
    |> Stream.map(fn
      ["mask", mask] ->
        {:mask, mask}

      [address_string, value] ->
        address_size = byte_size(address_string) - byte_size("mem[") - byte_size("]")
        <<"mem[", address::binary-size(address_size), "]">> = address_string
        {:memory, String.to_integer(address), String.to_integer(value)}
    end)
  end
end
