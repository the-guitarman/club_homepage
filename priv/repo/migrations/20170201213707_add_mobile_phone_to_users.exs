defmodule ClubHomepage.Repo.Migrations.AddMobilePhoneToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :mobile_phone, :string
    end
  end
end
