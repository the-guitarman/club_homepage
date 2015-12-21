defmodule ClubHomepage.Repo.Migrations.CreateAddress do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :district, :string
      add :street, :string
      add :zip_code, :string
      add :city, :string
      add :latitude, :float 
      add :longitude, :float

      timestamps
    end

  end
end
