defmodule ClubHomepage.Repo.Migrations.RenameMatchFlagAfterPenalties do
  use Ecto.Migration

  def change do
    rename table(:matches), :after_penalties, to: :after_penalty_shootout
  end
end
