defmodule ClubHomepage.Repo.Migrations.CreateMatchCommitments do
  use Ecto.Migration

  def change do
    create table(:match_commitments) do
      add :match_id, references(:matches)
      add :user_id, references(:users)
      add :commitment, :integer, null: true, limit: 1

      timestamps([type: :utc_datetime])
    end

    create unique_index(:match_commitments, [:match_id, :user_id])
  end
end
