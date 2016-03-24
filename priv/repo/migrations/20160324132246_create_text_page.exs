defmodule ClubHomepage.Repo.Migrations.CreateTextPage do
  use Ecto.Migration

  def change do
    create table(:text_pages) do
      add :key, :string
      add :text, :text

      timestamps
    end

    create unique_index(:text_pages, [:key])
  end
end
