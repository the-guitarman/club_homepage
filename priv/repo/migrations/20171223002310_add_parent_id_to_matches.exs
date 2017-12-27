defmodule ClubHomepage.Repo.Migrations.AddParentIdToMatches do
  use Ecto.Migration

  def change do
    alter table(:matches) do
      add :parent_id, references(:matches, on_delete: :nilify_all), null: true, default: nil
      #add :parent_id, :integer, default: 0
    end
  end
end
