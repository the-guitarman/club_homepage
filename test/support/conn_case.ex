defmodule ClubHomepage.Web.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      import ClubHomepage.Web.Router.Helpers

      # The default endpoint for testing
      @endpoint ClubHomepage.Web.Endpoint

      alias ClubHomepage.Repo
      import Ecto.Query, only: [from: 2]

      import ClubHomepage.Extension.CommonTestExtension

      def flash_messages_contain?(conn, text) do
        conn
        |> Phoenix.Controller.get_flash()
        |> Enum.any?(fn(item) -> String.contains?(elem(item, 1), text) end)
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ClubHomepage.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(ClubHomepage.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
