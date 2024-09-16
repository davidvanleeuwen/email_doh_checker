defmodule EmailDohCheckerTest do
  use ExUnit.Case
  doctest EmailDoHChecker

  alias EmailDoHChecker

  @tag :external
  test "valid domain" do
    assert EmailDoHChecker.valid?("example.com")
  end

  @tag :external
  test "valid email" do
    assert EmailDoHChecker.valid?("user@example.com")
  end

  @tag :external
  test "invalid domain" do
    refute EmailDoHChecker.valid?("nonexistentdomain1234.com")
  end

  @tag :external
  test "invalid email" do
    refute EmailDoHChecker.valid?("user@nonexistentdomain1234.com")
  end
end
