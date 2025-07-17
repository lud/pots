defmodule Pots.ModelTest do
  use Pots.DataCase

  alias Pots.Model

  describe "wealth" do
    test "currency 1 is always defined with amount 100 on fresh app" do
      assert 100 = Model.fetch_wealth!()
      assert 0 = Model.update_wealth!(-100)
      assert 10 = Model.update_wealth!(+10)
      assert 12 = Model.update_wealth!(+2)
      assert 0 = Model.update_wealth!(-12)

      # cannot go below zero
      assert_raise Ecto.InvalidChangesetError, fn ->
        Model.update_wealth!(-1) |> dbg()
      end
    end
  end
end
