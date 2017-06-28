defmodule ClubHomepage.Repo.Migrations.AddTokenSetAtToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :token_set_at, :utc_datetime
    end
  end
end
