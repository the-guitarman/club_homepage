defmodule ClubHomepage.Repo do
  use Ecto.Repo,
    otp_app: :club_homepage,
    adapter: Ecto.Adapters.Postgres
    #, adapter: Sqlite.Ecto

  import Ecto.Query, only: [from: 2]

  if Mix.env() in [:dev, :test] do
    @spec truncate(Ecto.Schema.t()) :: :ok
    def truncate(schema) do
      table_name = schema.__schema__(:source)
      ClubHomepage.Repo.query("TRUNCATE #{table_name}", [])
      :ok
    end

    @spec count(Ecto.Schema.t()) :: Ecto.Schema.t() | nil
    def count(model) do
      from(m in model, select: count(m.id))
      |> ClubHomepage.Repo.one()
    end
  end
end
