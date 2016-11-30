defmodule ClubHomepage.Repo.Migrations.AddMetaDataToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :meta_data, :map
    end
  end
end
