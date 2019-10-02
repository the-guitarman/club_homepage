defmodule ClubHomepage.FussballDeDataTest do
  use ClubHomepage.DataCase
  doctest ClubHomepage.FussballDeData

  alias ClubHomepage.FussballDeData
  #alias ClubHomepage.Team

  import ClubHomepage.Factory

  describe "fussball.de data" do
    #alias ClubHomepage.FussballDeData.SeasonTeamTable

    test "for team with table is off" do
      season = insert(:season)
      team = insert(:team, %{fussball_de_show_current_table: false})

      refute FussballDeData.get_season_team_table(team, season)
    end

    test "there's no season team table" do
      season = insert(:season)
      team = insert(:team, %{fussball_de_show_current_table: true})

      refute FussballDeData.get_season_team_table(team, season)
    end

    test "there's an empty season team table" do
      season = insert(:season)
      team = insert(:team, %{fussball_de_show_current_table: true})
      _season_team_table = insert(:season_team_table, %{season_id: season.id, team_id: team.id, html: ""})

      refute FussballDeData.get_season_team_table(team, season)
    end

    test "no club_rewrite or no team_id given" do
      season = insert(:season)
      team = insert(:team, %{fussball_de_show_current_table: true, fussball_de_team_rewrite: nil, fussball_de_team_id: nil})

      refute FussballDeData.get_season_team_table(team, season)
    end

    test "there's a season team table" do
      season = insert(:season)
      team = insert(:team, %{fussball_de_show_current_table: true, fussball_de_team_rewrite: "abc", fussball_de_team_id: "123"})
      season_team_table = insert(:season_team_table, %{season_id: season.id, team_id: team.id})

      stt = FussballDeData.get_season_team_table(team, season)
      assert season_team_table.id == stt.id
      assert stt.team_id == team.id
      assert stt.season_id == season.id
    end

    test "download and create the current season team table" do
      team = insert(:team, %{fussball_de_show_current_table: true, fussball_de_team_rewrite: "abc", fussball_de_team_id: "123"})

      stt = FussballDeData.create_or_update_current_team_table(team)
      assert is_binary(stt.html)
      assert stt.team_id == team.id
    end

    test "download and update the current season team table" do
      season = insert(:season, %{name: "2018-2019"})
      team = insert(:team, %{fussball_de_show_current_table: true, fussball_de_team_rewrite: "abc", fussball_de_team_id: "123"})
      season_team_table = insert(:season_team_table, %{season_id: season.id, team_id: team.id, html: "html"})

      stt = FussballDeData.create_or_update_current_team_table(team)
      assert stt.id == season_team_table.id
      assert stt.season_id == season.id
      assert stt.team_id == team.id
      assert is_binary(stt.html)
      assert stt.html != season_team_table.html
    end
  end
end

