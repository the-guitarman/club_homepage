defmodule ClubHomepage.Repo.Migrations.AddFailureReasonToMatches do
  use Ecto.Migration

  def change do
    alter table(:matches) do
      add :failure_reason, :string
    end
  end
end
