defmodule ClubHomepage.Repo.Migrations.AddMoreMatchFlags do
  use Ecto.Migration

  def change do
    alter table(:matches) do
      add :after_extra_time, :boolean, default: false
      add :after_penalties, :boolean, default: false
    end
  end
end
