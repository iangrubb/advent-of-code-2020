defmodule Encryption do

    def problem_one do
        8987316
        |> process_key()
        |> transform(14681524)
    end

    def process_key(key, {base, counter} \\ {1, 0}) do
        case transform(1, 7, base) do
            ^key -> counter + 1
            val -> process_key(key, {val, counter + 1})
        end
    end

    def transform(loop_size, subject_number, base \\ 1) do    
        Enum.reduce(1..loop_size, base, fn _, acc ->
            rem(subject_number * acc, 20201227)
        end)
    end
end