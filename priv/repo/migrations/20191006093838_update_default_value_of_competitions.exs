defmodule ClubHomepage.Repo.Migrations.UpdateDefaultValueOfCompetitions do
  use Ecto.Migration

  import Ecto.Query

  def change do
    query = from(c in ClubHomepage.Competition, where: is_nil(c.matches_need_decition))
    ClubHomepage.Repo.update_all(query, set: [matches_need_decition: false])
  end
end
