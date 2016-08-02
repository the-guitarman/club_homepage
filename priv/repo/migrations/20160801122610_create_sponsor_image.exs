defmodule ClubHomepage.Repo.Migrations.CreateSponsorImage do
  use Ecto.Migration

  def change do
    create table(:sponsor_images) do
      add :name, :string
      add :attachment, :string

      timestamps()
    end

  end
end
