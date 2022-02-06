defmodule ObjectStoreApp.OrganisationTest do
  use ObjectStoreApp.DataCase

  alias ObjectStoreApp.Organisations

  setup do
    on_exit(fn ->
      ObjectStoreApp.Store.delete_bucket("another")
      ObjectStoreApp.Store.delete_bucket("more")
      ObjectStoreApp.Store.delete_bucket("lmoa")
    end)
  end

  test "only one default is allowed" do
    assert {:ok, _} = Organisations.create("default", true)
    assert {:ok, _} = Organisations.create("another")
    assert {:ok, _} = Organisations.create("more")
    assert {:ok, _} = Organisations.create("lmoa")
    assert {:error, _} = Organisations.create("more-default", true)
  end
end
