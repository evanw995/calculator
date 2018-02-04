defmodule Calc do
  @moduledoc """
  Documentation for Calc.
  """

  def main do
    x = IO.gets "Enter operations: "
    result = eval(x)
    IO.puts result
    main()
  end

  def eval(x) do
    args = String.split(x, "")
    chop = Enum.count(args) - 3
    build_exp(Enum.slice(args, 0..chop), 0, 0)
  end

  # STATUS
  # 0 = none, begining value-- evaluate all expressions in parenthesis first
  # 1 = breaking up exp by -
  # 2 = breaking up exp by +
  # 3 = breaking up exp by /
  # 4 = breaking up exp by * (lowest level, first operation executed)
  # 5 = parse_arg

  # For evaluating expressions and dealing with parenthesis
  defp build_exp(args, x, status) when status == 0 do
  lastIndex = Enum.count(args) - 1
    cond do
      (Enum.at(args, x, "") == "(") ->
        closeParen = find_close_paren(args, x+1, 0) # Index of closing parenthesis
        parensExp = build_exp(Enum.slice(args, (x+1)..(closeParen-1)), 0, 0) # Expression inside parens
        # Expression before parens
        negative = ((x != 0) && (Enum.at(args, x-1, "") == "-") && is_negative(args, x-1))
        firstChop = 
          cond do
            x == 0 ->
              []
            ((x == 1) && (Enum.at(args, x-1, "") == "-")) ->
              []
            negative ->
              Enum.slice(args, 0..(x-2))
            true ->
              Enum.slice(args, 0..(x-1))
          end
        parensExpString = 
          case negative do
            true -> Integer.to_string(0 - parensExp)
            false -> Integer.to_string(parensExp)
          end
        middle = Enum.slice(String.split(parensExpString, ""), 0..(String.length(parensExpString)))
        newExp = Enum.concat([firstChop, [" "], middle, [" "], Enum.slice(args, (closeParen+1)..lastIndex)]) # Full expression
        build_exp(newExp, 0, 0)
      (x == lastIndex) ->
        build_exp(args, 0, 1)
      true ->
        build_exp(args, x+1, status)
    end
  end

  # For evaluating expressiong and dealing with order of operations
  defp build_exp(args, x, status) when status > 0 do
    lastIndex = Enum.count(args) - 1
    cond do
      (status == 5) ->
        parse_arg(args)
      (status == 1) && (Enum.at(args, x, "") == "-") && (is_negative(args, x)) ->
        # Check for negative sign vs. subtraction operator
        build_exp(args, x+1, status)
      (Enum.at(args, x, "") == status_operator(status)) ->
        if ((x == lastIndex) || (x == 0)) do
          raise("Invalid input")
        end
        first = build_exp(Enum.slice(args, 0..(x-1)), 0, status+1) # Does not need to check for same operator
        second = build_exp(Enum.slice(args, (x+1)..lastIndex), 0, status) # Needs to check for same operator
        calculate(first, second, status)
      (x == lastIndex) ->
        build_exp(args, 0, status+1)
      true ->
        build_exp(args, x+1, status)
    end
  end
  
  # Should not be called
  defp build_exp(args, x, status) do
    IO.puts "args: "
    IO.inspect args
    IO.puts "x: "
    IO.inspect x
    IO.puts "status: "
    IO.inspect status
    raise("Invalid input") # Should be covered in other cases
  end

  # Parses what should be a valid number argument
  defp parse_arg(xs) do
    cond do
      (Enum.at(xs, 0, "") == " ") -> # Remove leading spaces
        last = Enum.count(xs) - 1
        parse_arg(Enum.slice(xs, 1..last))
      true -> # Parse arg if possible
        tuple = Integer.parse(Enum.join(xs))
        if (!no_garbage(elem(tuple, 1), 0)) do
          raise("Invalid input") # Bad data!
        end
        elem(tuple, 0)
    end
  end

  # Makes sure any characters after integer are just trailing spaces
  defp no_garbage(str, x) do
    cond do
      (String.length(str) == x) ->
        true
      (String.at(str, x) != " ") ->
        false
      true ->
        no_garbage(str, x+1)
    end
  end

  # Finds and returns index of closing parenthesis
  defp find_close_paren(args, x, acc) do
    lastIndex = Enum.count(args) - 1
    cond do
      (x == lastIndex) && ((acc != 0) || (Enum.at(args, x, "") != ")")) ->
        raise("Invalid input")
      (Enum.at(args, x, "") == "(") ->
        find_close_paren(args, x+1, acc+1)
      (Enum.at(args, x, "") == ")") && (acc == 0) ->
        x
      (Enum.at(args, x, "") == ")") && (acc != 0) ->
        find_close_paren(args, x+1, acc-1)
      true ->
        find_close_paren(args, x+1, acc)
    end
  end

  # Calculate arguments based on status of expression
  defp calculate(first, second, status) do
    cond do
      (status == 1) ->
        first - second
      (status == 2) ->
        first + second
      (status == 3) ->
        round(first / second)
      (status == 4) ->
        first * second
    end
  end

  # Returns true if there is nothing before the "-" sign, or if there is an operator directly before it
  defp is_negative(args, x) do
    cond do
      (x == 0) ->
        true
      Enum.at(args, x-1, "") == "+" ->
        true
      Enum.at(args, x-1, "") == "-" ->
        true
      Enum.at(args, x-1, "") == "/" ->
        true
      Enum.at(args, x-1, "") == "*" ->
        true
      Enum.at(args, x-1, "") == " " ->
        is_negative(args, x-1)
      true ->
        false
    end
  end

  # Return string of operator to be checked by status 
  defp status_operator(x) do 
    cond do
      (x == 1) ->
        "-"
      (x == 2) ->
        "+"
      (x == 3) ->
        "/"
      (x == 4) ->
        "*"
    end
  end
end
