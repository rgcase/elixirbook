defmodule KVTest do
  use ExUnit.Case
  doctest KV

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "hello" do
    assert KV.hello == :world
  end
end
