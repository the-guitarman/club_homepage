defmodule ClubHomepage.Repo.Migrations.CreateMatchCommitments do
  use Ecto.Migration

  def change do
    create table(:match_commitments) do
      add :match_id, references(:matches)
      add :user_id, references(:users)
      add :commitment, :integer, null: false, default: 0, limit: 1

      timestamps()
    end

    create unique_index(:match_commitments, [:match_id, :user_id])
  end
end
