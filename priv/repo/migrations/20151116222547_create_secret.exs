defmodule ClubHomepage.Repo.Migrations.CreateSecret do
  use Ecto.Migration

  def change do
    create table(:secrets) do
      add :key, :string
      add :expires_at, :utc_datetime

      timestamps()
    end

  end
end
