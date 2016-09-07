defmodule ClubHomepage.Repo.Migrations.CreateTeamChatMessage do
  use Ecto.Migration

  def change do
    create table(:team_chat_messages) do
      add :message, :text
      add :team_id, references(:teams, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:team_chat_messages, [:team_id])
    create index(:team_chat_messages, [:user_id])

  end
end
