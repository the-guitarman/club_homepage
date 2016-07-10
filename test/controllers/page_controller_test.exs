defmodule ClubHomepage.PageControllerTest do
  use ClubHomepage.ConnCase

  import Ecto.Query, only: [from: 2]
  import ClubHomepage.Factory

  setup do
    conn = build_conn()
    {:ok, conn: conn}
  end

  test "GET /", %{conn: conn} do
    conn = get build_conn(), page_path(conn, :index)
    refute html_response(conn, 200) =~ "<h2>Latest News</h2>"
    refute html_response(conn, 200) =~ "<h2>Next Matches</h2>"
    refute html_response(conn, 200) =~ "<h2>Latest Match Results</h2>"

    _news = create(:news)
    _next_match = create(:match, start_at: add_days_to_date(Timex.DateTime.local))
    _last_match = create(:match, start_at: add_days_to_date(Timex.DateTime.local, -7))

    conn = get build_conn(), page_path(conn, :index)
    assert html_response(conn, 200) =~ "<h2>Latest News</h2>"
    assert html_response(conn, 200) =~ "<h2>Next Matches</h2>"
    assert html_response(conn, 200) =~ "<h2>Latest Match Results</h2>"

    query = from t in ClubHomepage.Team, select: count(t.id)
    [team_count] = ClubHomepage.Repo.all(query)
    if team_count > 0 do
      assert html_response(conn, 200) =~ "<h2>Teams</h2>"
    else
      refute html_response(conn, 200) =~ "<h2>Teams</h2>"
    end
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
    |> Timex.Date.add(Timex.Time.to_timestamp(days, :days))
  end
end
