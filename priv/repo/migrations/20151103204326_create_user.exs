defmodule ClubHomepage.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :active, :boolean, default: true
      add :birthday, :datetime

      add :login, :string
      add :email, :string
      add :password_hash, :string
      add :name, :string
      add :roles, :string, default: "member"

      timestamps
    end

  end
end
