defmodule ClubHomepage.Repo.Migrations.AddIndicesToUsers do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:login])
    create unique_index(:users, [:email])
  end
end
