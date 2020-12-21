defmodule Allergen do
  def problem_one do
    allergen_data = get_allergen_data()

    ingredient_by_allergen =
      allergen_data
      |> create_candidate_map()
      |> process_candidate_map()

    allergen_by_ingredient =
      ingredient_by_allergen
      |> Map.to_list()
      |> Enum.reduce(%{}, fn {allergen, ingredient}, map -> Map.put(map, ingredient, allergen) end)

    allergen_data
    |> Enum.reduce([], fn %{ingredients: ingredients}, acc ->
      ingredients
      |> Enum.filter(fn ing -> Map.get(allergen_by_ingredient, ing) == nil end)
      |> Enum.concat(acc)
    end)
    |> Enum.count()
  end

  def problem_two do
    allergen_data = get_allergen_data()

    ingredient_by_allergen =
      allergen_data
      |> create_candidate_map()
      |> process_candidate_map()

    ingredient_by_allergen
    |> Map.to_list()
    |> Enum.sort_by(fn {allergen, _ingredient} -> allergen end)
    |> Enum.map(fn {_allergen, ingredient} -> ingredient end)
    |> Enum.join(",")
  end

  def create_candidate_map(allergen_data) do
    allergen_data
    |> Enum.reduce(%{}, fn %{allergens: allergens, ingredients: ingredients}, candidates ->
      allergens
      |> Enum.reduce(candidates, fn allergen, candidates ->
        case Map.get(candidates, allergen) do
          nil ->
            Map.put(candidates, allergen, ingredients)

          previous_ingredients ->
            shared_ingredients =
              previous_ingredients
              |> Enum.concat(ingredients)
              |> Enum.frequencies()
              |> Map.to_list()
              |> Enum.filter(fn {_, frequency} -> frequency == 2 end)
              |> Enum.map(fn {ingredient, _} -> ingredient end)

            Map.put(candidates, allergen, shared_ingredients)
        end
      end)
    end)
  end

  def process_candidate_map(candidate_map) do
    pairs = Map.to_list(candidate_map)

    pairs
    |> Enum.map(fn {_, ingredients} -> ingredients end)
    |> remove_duplicates()
    |> Enum.zip(pairs)
    |> Enum.reduce(%{}, fn {[ingredient], {allergen, _}}, acc ->
      Map.put(acc, allergen, ingredient)
    end)
  end

  def remove_duplicates(groups) do
    groups
    |> Enum.with_index()
    |> Enum.map(fn {group, idx} ->
      elements = Enum.reduce(group, %{}, fn el, els -> Map.put(els, el, true) end)
      %{id: idx, elements: elements, count: Enum.count(group), processed: false}
    end)
    |> Enum.sort_by(fn %{count: count} -> count end)
    |> remove_duplicates_rec()
    |> Enum.sort_by(fn %{id: id} -> id end)
    |> Enum.map(fn %{elements: elements} ->
      elements
      |> Map.to_list()
      |> Enum.map(fn {el, true} -> el end)
    end)
  end

  def remove_duplicates_rec(groups) do
    singleton_group =
      Enum.find(groups, fn %{count: count, processed: processed} ->
        count == 1 and not processed
      end)

    updated_groups =
      case singleton_group do
        %{id: target_id, elements: singleton_elements} ->
          [{element, _}] = Map.to_list(singleton_elements)

          Enum.map(groups, fn %{id: id, elements: elements, count: count} = group ->
            cond do
              id == target_id ->
                %{group | processed: true}

              Map.get(elements, element) ->
                %{group | elements: Map.delete(elements, element), count: count - 1}

              true ->
                group
            end
          end)

        nil ->
          groups
      end

    # currently only needs to singleton scan, but could add in more complicated group scanning

    case groups == updated_groups do
      true -> groups
      false -> remove_duplicates_rec(updated_groups)
    end
  end

  def get_allergen_data do
    Path.join(__DIR__, "input.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn line ->
      line
      |> String.split(" ")
      |> Enum.split_while(fn line -> line != "(contains" end)
      |> List.wrap()
      |> Enum.map(fn {ingredients, allergens} ->
        cleaned_allergens =
          allergens
          |> Enum.filter(fn str -> str != "(contains" end)
          |> Enum.map(fn allergen ->
            allergen
            |> String.trim(")")
            |> String.trim(",")
          end)

        %{ingredients: ingredients, allergens: cleaned_allergens}
      end)
      |> Enum.at(0)
    end)
    |> Stream.scan([], fn datum, data -> [datum | data] end)
    |> Enum.at(-1)
  end
end
