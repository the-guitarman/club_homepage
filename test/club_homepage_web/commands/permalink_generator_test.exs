defmodule ClubHomepage.PermalinkGeneratorTest do
  use ClubHomepage.ModelCase
  use ExUnit.Case
  doctest ClubHomepageWeb.PermalinkGenerator

  alias ClubHomepage.Permalink
  alias ClubHomepageWeb.PermalinkGenerator
  alias ClubHomepage.Team

  import ClubHomepage.Factory
  import Ecto.Query, only: [from: 2]

  test "delete if a new object with same slug is created" do
    assert 0 == Repo.one(query())
    Permalink.changeset(%Permalink{}, %{source_path: "/teams/new-team", destination_path: "/teams/team-2"})
    |> Repo.insert()
    assert 1 == Repo.one(query())

    PermalinkGenerator.run(create_team(), :teams)
    assert 0 == Repo.one(query())
  end

  test "create if an object changes its slug" do
    create_team()
    team = Repo.get_by!(Team, name: "New Team")
    changeset = Team.changeset(team, %{name: "New Team 2"})
    Repo.update(changeset)
    PermalinkGenerator.run(changeset, :teams)
    assert 1 == Repo.one(query())
    permalink = Repo.one(Permalink)
    assert "/teams/new-team" == permalink.source_path
    assert "/teams/new-team-2" == permalink.destination_path
  end

  defp query do
    from(p in Permalink, select: count(p.id))
  end

  defp create_team do
    competition = insert(:competition)
    changeset = Team.changeset(%Team{}, %{competition_id: competition.id, name: "New Team"})
    Repo.insert(changeset)
    changeset
  end
end
