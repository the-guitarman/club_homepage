defmodule ClubHomepage.ConnCase do
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

      alias ClubHomepage.Repo
      import Ecto.Model, except: [build: 2]
      import Ecto.Query, only: [from: 2]

      import ClubHomepage.Router.Helpers

      # The default endpoint for testing
      @endpoint ClubHomepage.Endpoint

      defp get_highest_id(module) do
        query = from t in module, select: max(t.id)
        case Repo.all(query) do
          [nil] -> 0
          [id]  -> id
        end
      end

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
