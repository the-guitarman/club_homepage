defmodule ClubHomepage.Repo.Migrations.CreatePermalink do
  use Ecto.Migration

  def change do
    create table(:permalinks) do
      add :source_path, :string
      add :destination_path, :string

      timestamps([type: :utc_datetime])
    end

  end
end
