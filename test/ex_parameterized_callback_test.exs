defmodule ExParameterizedParamsCallbackTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized

  setup do
    {:ok, [hello: "world", value: 1, bool: false]}
  end

  test "ast format when one param with context" do
    import ExUnit.Parameterized.ParamsCallback
    assert (
      quote do
        test_with_params "ast test", context, fn (a) -> a == "test" end do
          [{"test"}]
        end
      end
      |> Macro.to_string) == String.strip ~S"""
        test_with_params("ast test", context, fn a -> a == "test" end) do
          [{"test"}]
        end
        """
  end

  test "ast format when two param with context" do
    import ExUnit.Parameterized.ParamsCallback
    assert (
      quote do
        test_with_params "ast test", context, fn (a, b) -> assert a + b == 2 end do
          [{1, 2}]
        end
      end
      |> Macro.to_string) == String.strip ~S"""
        test_with_params("ast test", context, fn a, b -> assert(a + b == 2) end) do
          [{1, 2}]
        end
        """
  end

  @tag skip: "If failed to skip, test will fai"
  test_with_params "skipped test with context", context,
    fn (a) ->
      assert a == true
    end do
      [
        {context[:bool]}
      ]
  end

  test_with_params "provide one param with context", context,
    fn (a) ->
      assert a == 1
    end do
      [
        { context[:value] },
        "two values": { context[:value] }
      ]
  end

  test_with_params "compare two values with context", context,
    fn (a, expected) ->
      assert a == expected
    end do
      [
        {context[:value], return_one()}, # Can set other functions
        "two values": {context[:hello], return_world()} # Can set other functions
      ]
  end
  defp return_one, do: 1
  defp return_world, do: "world"

  test_with_params "add params with context", context,
    fn (a, b, expected) ->
      assert a + b == expected
    end do
      [
        {context[:value], 2, 3}
      ]
  end

  test_with_params "create wordings with context", context,
    fn (a, b, expected) ->
      str = a <> " and " <> b
      assert str == expected
    end do
      [
        {context[:hello], "cats", "world and cats"},
        {"hello", context[:hello], "hello and world"}
      ]
  end

  test_with_params "fail case with context", context,
    fn (a, b, expected) ->
      refute a + b == expected
    end do
      [
        {context[:value], 2, 2}
      ]
  end

  test_with_params "add description for each params with context", context,
    fn (a, b, expected) ->
      str = a <> " and " <> b
      assert str == expected
    end do
      [
        "description for param1": {context[:hello], "cats", "world and cats"},
        "description for param2": {"hello", context[:hello], "hello and world"}
      ]
  end

  test_with_params "mixed no desc and with desc for each params with context", context,
    fn (a, b, expected) ->
      str = a <> " and " <> b
      assert str == expected
    end do
      [
        {context[:hello], "cats", "world and cats"}, # no description
        "description for param2": {"hello", context[:hello], "hello and world"} # with description
      ]
  end
end
