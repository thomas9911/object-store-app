defmodule ObjectStoreApp.UserTest do
  use ObjectStoreApp.DataCase

  alias ObjectStoreApp.Users
  alias ObjectStoreApp.Users.User

  describe "create user returns correct formatted user" do
    setup do
      on_exit(fn ->
        ObjectStoreApp.Users.delete("test")
      end)
    end

    test "" do
      assert {:ok,
              %User{
                id: id,
                inserted_at: %DateTime{},
                updated_at: %DateTime{},
                password: "$argon2id$v=19$m=256,t=1,p=2" <> _,
                username: "test"
              }} = Users.create("test", "test")

      assert {:ok, _} = Ecto.UUID.cast(id)
    end
  end

  describe "get user" do
    setup do
      on_exit(fn ->
        ObjectStoreApp.Users.delete("test")
      end)

      {:ok, user} = Users.create("test", "test")
      %{user: user}
    end

    test "works", %{user: user} do
      assert {:ok, %User{username: "test"}} = Users.get(user.username)
    end

    test "returns error on not found" do
      assert {:error, :user_not_found} = Users.get("not found")
    end
  end

  describe "login user" do
    setup do
      on_exit(fn ->
        ObjectStoreApp.Users.delete("test")
      end)

      {:ok, user} = Users.create("test", "test")
      %{user: user}
    end

    test "works", %{user: user} do
      assert {:ok, %User{username: "test"}} = Users.login(user.username, "test")
    end

    test "invalid password", %{user: user} do
      assert {:error, "invalid password"} = Users.login(user.username, "asdfg")
    end

    test "user not found" do
      assert {:error, :user_not_found} = Users.login("asdfgh", "asdfg")
    end
  end
end
