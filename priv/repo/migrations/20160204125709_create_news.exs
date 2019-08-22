defmodule ClubHomepage.Repo.Migrations.CreateNews do
  use Ecto.Migration

  def change do
    create table(:news) do
      add :public, :boolean, default: false
      add :subject, :string
      add :body, :text

      timestamps([type: :utc_datetime])
    end

  end
end
