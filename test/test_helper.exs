{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start

#Ecto.Adapters.SQL.Sandbox.mode(ClubHomepage.Repo, :manual)
Ecto.Adapters.SQL.Sandbox.mode(ClubHomepage.Repo, {:shared, self()})
