defmodule ClubHomepage.Repo.Migrations.AddEmailToSecrets do
  use Ecto.Migration

  def change do
    alter table(:secrets) do
      add :email, :string
    end
  end
end
