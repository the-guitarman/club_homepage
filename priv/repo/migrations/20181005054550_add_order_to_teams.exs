defmodule ClubHomepage.Repo.Migrations.AddOrderToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :order, :integer
    end
  end
end
