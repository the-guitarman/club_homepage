defmodule ClubHomepage.Repo.Migrations.CreatePermalink do
  use Ecto.Migration

  def change do
    create table(:permalinks) do
      add :source_path, :string
      add :destination_path, :string

      timestamps()
    end

  end
end
