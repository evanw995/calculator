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
    IO.inspect x
    args = String.split(x, "")
    chop = Enum.count(args) - 3
    build_exp(Enum.slice(args, 0..chop), 0, 0)
  end

  # STATUS
  # 0 = none, begining value-- evaluate all expressions in parenthesis first
  # 1 = breaking up exp by -
  # 2 = breaking up exp by +
  # 3 = breaking up exp by /
  # 4 = breaking up exp by *
  # 5 = parse_arg

  def build_exp(args, x, status) when status == 0 do
  lastIndex = Enum.count(args) - 1
    cond do
      (Enum.at(args, x, "") == "(") ->
        # IO.puts "parens caught"
        closeParen = find_close_paren(args, x+1, 0)
        # IO.inspect closeParen
        parensExp = build_exp(Enum.slice(args, (x+1)..(closeParen-1)), 0, 0)
        # IO.inspect parensExp
        # IO.puts "new expression"
        firstChop = 
          case x do
            0 -> []
            _ -> Enum.slice(args, 0..(x-1))
          end
        parensExpString = Integer.to_string(parensExp)
        middle = Enum.slice(String.split(parensExpString, ""), 0..(String.length(parensExpString)))
        # IO.inspect [Enum.slice(args, 0..(x-1)), [" ", Integer.to_string(parensExp), " "], Enum.slice(args, (closeParen+1)..lastIndex)]
        newExp = Enum.concat([firstChop, [" "], middle, [" "], Enum.slice(args, (closeParen+1)..lastIndex)])
        build_exp(newExp, 0, 0)
      (x == lastIndex) ->
        build_exp(args, 0, 1)
      true ->
        build_exp(args, x+1, status)
    end
  end

  ## need to also check for negative sign when parsing this
  ## way to do this is by checking if there is an arg in the slice before the "-" sign
  def build_exp(args, x, status) when status > 0 do
    lastIndex = Enum.count(args) - 1
    cond do
      (status == 5) ->
        parse_arg(args)
      (status == 1) && (Enum.at(args, x, "") == "-") && (is_negative(args, x)) -> # (x == 0) || (no_garbage(Enum.join(Enum.slice(args, 0..(x-1))), 0)) || 
        # Check for negative sign vs. subtraction operator
        # IO.puts "shouldnt be here"
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
  
  def build_exp(args, x, status) do
    IO.puts "args: "
    IO.inspect args
    IO.puts "x: "
    IO.inspect x
    IO.puts "status: "
    IO.inspect status
    raise("Invalid input") # Should be covered in other cases
  end

  def parse_arg(xs) do
    cond do
      (Enum.at(xs, 0, "") == " ") -> # Remove leading spaces
        last = Enum.count(xs) - 1
        parse_arg(Enum.slice(xs, 1..last))
      true -> # Parse arg if possible
        tuple = Integer.parse(Enum.join(xs))
        # IO.inspect tuple
        if (!no_garbage(elem(tuple, 1), 0)) do
          raise("Invalid input") # Bad data!
        end
        elem(tuple, 0)
    end
  end

  # Makes sure any characters after integer are just trailing spaces
  def no_garbage(str, x) do
    cond do
      (String.length(str) == x) ->
        true
      (String.at(str, x) != " ") ->
        false
      true ->
        no_garbage(str, x+1)
    end
  end

  def find_close_paren(args, x, acc) do
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
  def calculate(first, second, status) do
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
  def is_negative(args, x) do
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
  def status_operator(x) do 
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
