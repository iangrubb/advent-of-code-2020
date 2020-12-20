defmodule Image do

    def problem_one do
        {rules, messages} = get_data()

        messages
        |> Enum.filter(fn message -> message_matches_rule?(message, rules, "0") end)
        |> Enum.count()
    end

    def problem_two do
        {rules, messages} = get_data()
        
        patched_rules =
            rules
            |> Map.put("8", [["42"], ["42", "8"]])
            |> Map.put("11", [["42", "31"], ["42", "11", "31"]] )

        messages
        |> Enum.filter(fn message -> message_matches_rule?(message, patched_rules, "0") end)
        |> Enum.count()
    end

    def message_matches_rule?(message, rules, rule_key) do

        exact_match_count =
            message
            |> prefix_matches(rules, rule_key)
            |> Enum.filter(fn remainder -> remainder == "" end)
            |> Enum.count()

        exact_match_count > 0
    end

    def prefix_matches(message, rules, rule_key) do
        rules
        |> Map.get(rule_key)
        |> Enum.map(fn option ->
            
            option
            |> Enum.reduce([message], fn
                "a", remainders -> apply_prefix_to_remainders(remainders, "a")
                "b", remainders -> apply_prefix_to_remainders(remainders, "b")
                key, remainders -> Enum.flat_map(remainders, fn remainder -> prefix_matches(remainder, rules, key) end)
            end)

        end)
        |> Enum.concat()
        |> Enum.uniq()
    end

    def apply_prefix_to_remainders(remainders, prefix) do
        remainders
        |> Enum.filter(fn remainder -> String.starts_with?(remainder, prefix) end)
        |> Enum.map(fn remainder ->
            {_, result} = String.split_at(remainder, String.length(prefix))
            result
        end)
    end

    def get_data() do
        Path.join(__DIR__, "input.txt")
        |> File.stream!()
        |> Stream.map(&String.trim/1)
        |> Stream.scan({%{}, nil}, fn
            "", {rules, nil} -> {rules, []}
            rule_string, {rules, nil} ->
                [key, value] = String.split(rule_string, ":")
                {Map.put(rules, key, format_rule(value)), nil}
            message, {rules, messages} -> {rules, [message | messages]}
        end)
        |> Enum.at(-1)
    end

    def format_rule(rule_string) do

        rule_string
        |> String.split(" ")
        |> Enum.filter(fn str -> str != "" end)
        |> Enum.map(fn
            "\"a\"" -> "a"
            "\"b\"" -> "b"
            char -> char
        end)
        |> Enum.reduce([[]], fn
            "|", [first_rule] -> [[], first_rule]
            char, [rule | remainder] -> [ rule ++ [char] | remainder]
        end)

    end

end