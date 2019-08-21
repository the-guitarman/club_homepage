defmodule ClubHomepage.MatchControllerTest do
  use ClubHomepageWeb.ConnCase

  alias ClubHomepage.Match

  import ClubHomepage.Factory

  import Ecto.Query, only: [from: 2]
  import ClubHomepageWeb.UserRole, only: [has_role?: 2]

  @valid_attrs %{competition_id: 1, season_id: 1, team_id: 1, opponent_team_id: 1, home_match: true, start_at: "2010-04-17 14:00"}
  @invalid_attrs %{}

  setup context do
    conn = build_conn()
    competition   = insert(:competition)
    season        = insert(:season)
    team          = insert(:team)
    opponent_team = insert(:opponent_team)
    valid_attrs = %{@valid_attrs | competition_id: competition.id, season_id: season.id, team_id: team.id, opponent_team_id: opponent_team.id}
    if context[:login] do
      current_user = 
        if context[:user_roles] do
          insert(:user, roles: context[:user_roles])
        else
          insert(:user)
        end
      conn = assign(conn, :current_user, current_user)
      {:ok, conn: conn, current_user: current_user, valid_attrs: valid_attrs}
    else
      {:ok, conn: conn, valid_attrs: valid_attrs}
    end
  end

  @tag login: false
  test "requires user authentication on all actions", %{conn: conn, valid_attrs: valid_attrs} do
    match = insert(:match)
    Enum.each([
      get(conn, match_path(conn, :index)),
      get(conn, match_path(conn, :new)),
      post(conn, match_path(conn, :create), match: valid_attrs),
      get(conn, match_path(conn, :edit, match)),
      put(conn, match_path(conn, :update, match), match: valid_attrs),
      delete(conn, match_path(conn, :delete, match))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index with a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    conn = get conn, match_path(conn, :index)
    assert html_response(conn, 200) =~ "All Matches"
  end

  @tag login: true
  test "renders form for new resources with a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    conn = get conn, match_path(conn, :new)
    assert html_response(conn, 200) =~ "Create Match"
  end

  @tag login: true
  test "renders form for new bulk matches with a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    conn = get conn, matches_path(conn, :new_bulk)
    assert html_response(conn, 200) =~ "<h2>Create Several Matches From JSON-String</h2>"
  end

  @tag login: true
  test "creates a match and redirects when data is valid and a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: valid_attrs} do
    query = from(m in Match, select: count(m.id))
    assert 0 == Repo.one(query)
    conn = post conn, match_path(conn, :create), match: valid_attrs
    {:ok, start_at} =
    valid_attrs.start_at
    |> Timex.parse("%Y-%m-%d %H:%M", :strftime)
    {:ok, start_at} =
      start_at
      |> Timex.add(Timex.Duration.from_days(7))
      |> Timex.format("%Y-%m-%d %H:%M", :strftime)
    #assert redirected_to(conn) == match_path(conn, :index, %{"season_id" => valid_attrs.season_id, "team_id" => valid_attrs.team_id, "start_at" => start_at})
    team = Repo.get(ClubHomepage.Team, valid_attrs.team_id)
    season = Repo.get(ClubHomepage.Season, valid_attrs.season_id)
    assert redirected_to(conn) == team_page_with_season_path(conn, :show, team.slug, season.name, %{"season_id" => valid_attrs.season_id, "team_id" => valid_attrs.team_id, "start_at" => start_at, "competition_id" => valid_attrs.competition_id})
    assert 1 == Repo.one(query)
  end

  # @tag login: true
  # test "creates a match and redirects when data is valid and a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: valid_attrs} do
  #   query = from(m in Match, select: count(m.id))
  #   assert 0 == Repo.one(query)
  #   conn = post conn, match_path(conn, :create_bulk_matches), match: %{}

  # end

  @tag login: true
  test "does not create a match and renders errors when data is invalid and a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    conn = post conn, match_path(conn, :create), match: @invalid_attrs
    assert html_response(conn, 200) =~ "Create Match"
  end

  # @tag login: true
  # test "does not create a match and renders errors when data is invalid and a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
  #   conn = post conn, match_path(conn, :create_bulk_matches), match: %{}
  #   assert html_response(conn, 200) =~ "Create Matches"
  # end

  @tag login: false
  test "shows a future match without a user is logged in", %{conn: conn, valid_attrs: _valid_attrs} do
    start_at = Timex.local |> Timex.add(Timex.Duration.from_days(7))

    match = insert(:match, %{start_at: start_at})
    team = Repo.get!(ClubHomepage.Team, match.team_id)
    opponent_team = Repo.get!(ClubHomepage.OpponentTeam, match.opponent_team_id)
    conn = get conn, match_path(conn, :show, match)
    headline = 
    if match.home_match do
      ~r|<h2>.+?#{team.name}.+? - .+?#{opponent_team.name}.+?</h2>|s
    else
      ~r|<h2>.+?#{opponent_team.name}.+? - .+?#{team.name}.+?</h2>|s
    end
    assert html_response(conn, 200) =~ headline
    assert not (html_response(conn, 200) =~ ~r|<div class="row js-match-event-buttons css-match-event-buttons">|)
    assert not (html_response(conn, 200) =~ ~r|<div id="match-timeline"|)
  end

  @tag login: false
  test "shows a running match without a user is logged in", %{conn: conn, valid_attrs: _valid_attrs} do
    start_at = Timex.local |> Timex.add(Timex.Duration.from_hours(-1))

    match = insert(:match, %{start_at: start_at})
    team = Repo.get!(ClubHomepage.Team, match.team_id)
    opponent_team = Repo.get!(ClubHomepage.OpponentTeam, match.opponent_team_id)
    conn = get conn, match_path(conn, :show, match)
    headline = 
    if match.home_match do
      ~r|<h2>.+?#{team.name}.+? - .+?#{opponent_team.name}.+?</h2>|s
    else
      ~r|<h2>.+?#{opponent_team.name}.+? - .+?#{team.name}.+?</h2>|s
    end
    assert html_response(conn, 200) =~ headline
    assert not (html_response(conn, 200) =~ ~r|<div class="row js-match-event-buttons css-match-event-buttons">|)
    assert not (html_response(conn, 200) =~ ~r|<div id="match-timeline"|)
  end

  @tag login: true
  test "shows a future match with a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    start_at = Timex.local |> Timex.add(Timex.Duration.from_days(7))

    match = insert(:match, %{start_at: start_at})
    team = Repo.get!(ClubHomepage.Team, match.team_id)
    opponent_team = Repo.get!(ClubHomepage.OpponentTeam, match.opponent_team_id)
    conn = get conn, match_path(conn, :show, match)
    assert has_role?(conn, "match-editor")
    headline = 
      if match.home_match do
        ~r|<h2>.+?#{team.name}.+? - .+?#{opponent_team.name}.+?</h2>|s
      else
        ~r|<h2>.+?#{opponent_team.name}.+? - .+?#{team.name}.+?</h2>|s
      end
    assert html_response(conn, 200) =~ headline
    assert not (html_response(conn, 200) =~ ~r|<div class="row js-match-event-buttons css-match-event-buttons">|)
    assert not (html_response(conn, 200) =~ ~r|<div id="match-timeline"|)
  end

  @tag login: true
  @tag user_roles: "member match-editor"
  test "shows a running match with a match editor user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    start_at = Timex.local |> Timex.add(Timex.Duration.from_hours(-1))

    match = insert(:match, %{start_at: start_at})
    team = Repo.get!(ClubHomepage.Team, match.team_id)
    opponent_team = Repo.get!(ClubHomepage.OpponentTeam, match.opponent_team_id)
    conn = get conn, match_path(conn, :show, match)
    assert has_role?(conn, "match-editor")
    headline = 
      if match.home_match do
        ~r|<h2>.+?#{team.name}.+? - .+?#{opponent_team.name}.+?</h2>|s
      else
        ~r|<h2>.+?#{opponent_team.name}.+? - .+?#{team.name}.+?</h2>|s
      end
    assert html_response(conn, 200) =~ headline
    match_timeline_is_visible = html_response(conn, 200) =~ ~r|<div id="match-timeline"|
    match_event_buttons_are_visible = html_response(conn, 200) =~ ~r|<div class="row js-match-event-buttons css-match-event-buttons">|
    if ClubHomepage.Extension.Common.get_config(:show_match_timeline) do
      assert match_timeline_is_visible
      assert match_event_buttons_are_visible
    else
      assert !match_timeline_is_visible
      assert !match_event_buttons_are_visible
    end
  end

  @tag login: true
  @tag user_roles: "member"
  test "shows a running match with a no match editor user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    start_at = Timex.local |> Timex.add(Timex.Duration.from_hours(-1))

    match = insert(:match, %{start_at: start_at})
    team = Repo.get!(ClubHomepage.Team, match.team_id)
    opponent_team = Repo.get!(ClubHomepage.OpponentTeam, match.opponent_team_id)
    conn = get conn, match_path(conn, :show, match)
    assert not has_role?(conn, "match-editor")
    headline = 
    if match.home_match do
      ~r|<h2>.+?#{team.name}.+? - .+?#{opponent_team.name}.+?</h2>|s
    else
      ~r|<h2>.+?#{opponent_team.name}.+? - .+?#{team.name}.+?</h2>|s
    end
    assert html_response(conn, 200) =~ headline
    match_timeline_is_visible = html_response(conn, 200) =~ ~r|<div id="match-timeline"|
    match_event_buttons_are_not_visible = not(html_response(conn, 200) =~ ~r|<div class="row js-match-event-buttons css-match-event-buttons">|)
    if ClubHomepage.Extension.Common.get_config(:show_match_timeline) do
      assert match_timeline_is_visible
      assert match_event_buttons_are_not_visible
    else
      assert not(match_timeline_is_visible)
      assert match_event_buttons_are_not_visible
    end
  end

  @tag login: true
  # test "tries to render page not found when id is nonexistent and no user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
  #   #assert_error_sent 404, fn ->
  #     get conn, match_path(conn, :show, -1)
  #   #end
  #   IO.inspect conn
  #   assert redirected_to(conn) =~ "/"
  # end

  @tag login: false
  test "renders page not found when id is nonexistent and no user is logged in", %{conn: conn, valid_attrs: _valid_attrs} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, match_path(conn, :show, -1)
    end
  end

  @tag login: true
  test "renders page not found when id is nonexistent and a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, match_path(conn, :show, -1)
    end
  end

  @tag login: true
  test "renders form for editing chosen resource with a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    match = Repo.insert! %Match{}
    conn = get conn, match_path(conn, :edit, match)
    assert html_response(conn, 200) =~ "Edit Match"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid and a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: valid_attrs} do
    query = from(m in Match, select: count(m.id), where: m.home_match == true)

    assert 0 == Repo.one(query)

    match = Repo.insert! %Match{home_match: true}
    assert match.home_match == true
    assert 1 == Repo.one(query)

    attributes = %{valid_attrs | home_match: false}
    conn = put conn, match_path(conn, :update, match), match: attributes
    assert redirected_to(conn) == match_path(conn, :show, match)

    updated_match = Repo.get_by(Match, id: match.id)
    assert updated_match
    assert updated_match.home_match == false
    assert 0 == Repo.one(query)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    match = Repo.insert! %Match{}
    conn = put conn, match_path(conn, :update, match), match: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Match"
  end

  @tag login: true
  test "deletes chosen resource with a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    match = insert(:match)
    team = Repo.get!(ClubHomepage.Team, match.team_id)
    conn = delete conn, match_path(conn, :delete, match)
    #assert redirected_to(conn) == match_path(conn, :index)
    assert redirected_to(conn) == ClubHomepage.Extension.CommonSeason.team_with_season_path(conn, team)
    refute Repo.get(Match, match.id)
  end

  def prepare_next_match_parameters(%{"season_id" => season_id, "team_id" => team_id, "start_at" => start_at}) do
    %{"season_id" => season_id, "team_id" => team_id, "start_at" => start_at}
  end
end
