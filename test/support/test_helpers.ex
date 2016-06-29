defmodule ClubHomepage.TestHelpers do
  # alias ClubHomepage.Repo

  ExUnit.start

  Ecto.Adapters.SQL.Sandbox.mode(ClubHomepage.Repo, :manual)
end
