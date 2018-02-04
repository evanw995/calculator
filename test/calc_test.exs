defmodule CalcTest do
  use ExUnit.Case
  doctest Calc

  test "Basic operations" do
    assert Calc.eval("5 + 5 * 5\n") == 30
    assert Calc.eval("(5 + 5) * 5\n") == 50
    assert Calc.eval("5 + 5 * 5 - 5\n") == 25
    assert Calc.eval("5 + 5 * -5\n") == -20
    assert Calc.eval("(5 + 5 * 5) / 15\n") == 2
    assert Calc.eval("5 / 5 * 5\n") == 0
  end

  test "Parenthesis interpretation" do
    assert Calc.eval("(((5))) + (5 * 5)\n") == 30
    assert Calc.eval("((5 + 5) * 5)\n") == 50
  end

  test "Negative sign interpretation" do
    assert Calc.eval("-5 + 5\n") == 0
    assert Calc.eval("    -5 + 5\n") == 0
    assert Calc.eval("5 + (-5 * 5)\n") == -20
    assert Calc.eval("5 + -(5 * 5)\n") == -20
    assert Calc.eval("5 + (-5) * 5\n") == -20
    assert Calc.eval("-5--5\n") == 0
    assert Calc.eval("-5+-5\n") == -10
    assert Calc.eval("-(5 * 5)\n") == -25
    assert Calc.eval("5--(5 * 5)\n") == 30
  end

  test "bad input" do
    assert_raise RuntimeError, fn ->
      Calc.eval("((5))) + (5 * 5)\n")
    end
    assert_raise ArgumentError, fn ->
      Calc.eval("--(5)\n")
    end
    assert_raise ArgumentError, fn ->
      Calc.eval("- 5\n")
    end
    assert_raise RuntimeError, fn ->
      Calc.eval("(((5) + (5 * 5)\n")
    end
    assert_raise ArgumentError, fn ->
      Calc.eval("5 +- (5 * 5)\n")
    end
    assert_raise ArgumentError, fn ->
      Calc.eval("5 + --(5 * 5)\n")
    end
    assert_raise ArgumentError, fn ->
      Calc.eval("A + (5 * 5)\n")
    end
    assert_raise RuntimeError, fn ->
      Calc.eval("12lk34j\n")
    end
    assert_raise RuntimeError, fn ->
      Calc.eval("+ (5 * 5)\n")
    end
    assert_raise ArgumentError, fn ->
      Calc.eval(")(5 * 5)\n")
    end
    assert_raise ArgumentError, fn ->
      Calc.eval("((5)) + \n")
    end
  end
end
