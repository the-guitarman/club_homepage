defmodule ClubHomepage.PageControllerTest do
  use ClubHomepage.Web.ConnCase

  import ClubHomepage.Factory

  setup do
    conn = build_conn()
    {:ok, conn: conn}
  end

  test "GET /", %{conn: conn} do
    conn = get build_conn(), page_path(conn, :index)
    assert html_response(conn, 200) =~ "<h2>Latest News</h2>"
    assert html_response(conn, 200) =~ "There are no news at the moment."
    refute html_response(conn, 200) =~ "<h2>Next Matches</h2>"
    refute html_response(conn, 200) =~ "<h2>Latest Match Results</h2>"

    _news = insert(:news)
    _next_match = insert(:match, start_at: add_days_to_date(Timex.local))
    _last_match = insert(:match, start_at: add_days_to_date(Timex.local, -7))

    conn = get build_conn(), page_path(conn, :index)
    assert html_response(conn, 200) =~ "<h2>Latest News</h2>"
    assert html_response(conn, 200) =~ "<h2>Next Matches</h2>"
    assert html_response(conn, 200) =~ "<h2>Latest Match Results</h2>"
  end

  test "GET / with no or inactive teams only", %{conn: conn} do
    ClubHomepage.Repo.update_all(ClubHomepage.Team, set: [active: false])

    conn = get build_conn(), page_path(conn, :index)

    assert html_response(conn, 200) =~ "<h2>Teams</h2>"
    assert html_response(conn, 200) =~ "<p>There are no teams at the moment.</p>"
  end

  test "GET / with active and inactive teams", %{conn: conn} do
    team_1 = insert(:team, active: true)
    team_2 = insert(:team, active: false)

    conn = get build_conn(), page_path(conn, :index)

    assert html_response(conn, 200) =~ "<h2>Teams</h2>"
    refute html_response(conn, 200) =~ "<p>There are no teams at the moment.</p>"
    assert html_response(conn, 200) =~ team_1.name
    refute html_response(conn, 200) =~ team_2.name
  end

  test "GET /cronicle.html", %{conn: conn} do
    conn = get build_conn(), page_path(conn, :chronicle)
    assert html_response(conn, 200) =~ "<h1>Chronicle</h1>"
  end

  test "GET /contact.html", %{conn: conn} do
    conn = get build_conn(), page_path(conn, :contact)
    assert html_response(conn, 200) =~ "<h1>Contact</h1>"
  end

  test "GET /registration-information.html", %{conn: conn} do
    conn = get build_conn(), page_path(conn, :registration_information)
    assert html_response(conn, 200) =~ "<h1>Registration Information</h1>"
  end

  test "GET /sponsors.html", %{conn: conn} do
    conn = get build_conn(), page_path(conn, :sponsors)
    assert html_response(conn, 200) =~ "<h1>Sponsors</h1>"
  end

  test "GET /about-us.html", %{conn: conn} do
    conn = get build_conn(), page_path(conn, :about_us)
    assert html_response(conn, 200) =~ "<h1>About Us</h1>"
  end

  defp add_days_to_date(date, days \\ 7) do
    date
    |> Timex.add(Timex.Duration.from_days(days))
  end
end
