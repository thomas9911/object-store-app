defmodule ObjectStoreApp.RoundTripTest do
  use ObjectStoreApp.DataCase

  test "create user and delete organisation are inverses" do
    Enum.each(0..1, fn _ ->
      ObjectStoreApp.Users.create("roundtrip-test", "test", "organisation_one")
      ObjectStoreApp.Organisations.delete("organisation_one")
    end)
  end
end
