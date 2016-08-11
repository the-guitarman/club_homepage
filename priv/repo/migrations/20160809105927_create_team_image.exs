defmodule ClubHomepage.Repo.Migrations.CreateTeamImage do
  use Ecto.Migration

  def change do
    create table(:team_images) do
      add :year, :integer
      add :attachment, :string
      add :description, :text
      add :team_id, references(:teams, on_delete: :nothing)

      timestamps()
    end
    create index(:team_images, [:team_id])

  end
end
