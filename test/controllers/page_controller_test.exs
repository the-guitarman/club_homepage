defmodule ClubHomepage.PageControllerTest do
  use ClubHomepage.ConnCase

  import Ecto.Query, only: [from: 2]

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "GET /", %{conn: conn} do
    conn = get conn(), page_path(conn, :index)
    assert html_response(conn, 200) =~ "<h2>Latest News</h2>"
    assert html_response(conn, 200) =~ "<h2>Latest Match Results</h2>"

    query = from t in ClubHomepage.Team, select: count(t.id)
    [team_count] = ClubHomepage.Repo.all(query)
    if team_count > 2 do
      assert html_response(conn, 200) =~ "<h2>Teams</h2>"
    else
      refute html_response(conn, 200) =~ "<h2>Teams</h2>"
    end
  end

  test "GET /cronicle.html", %{conn: conn} do
    conn = get conn(), page_path(conn, :chronicle)
    assert html_response(conn, 200) =~ "<h1>Chronicle</h1>"
  end

  test "GET /contact.html", %{conn: conn} do
    conn = get conn(), page_path(conn, :contact)
    assert html_response(conn, 200) =~ "<h1>Contact</h1>"
  end

  test "GET /registration-information.html", %{conn: conn} do
    conn = get conn(), page_path(conn, :registration_information)
    assert html_response(conn, 200) =~ "<h1>Registration Information</h1>"
  end

  test "GET /sponsors.html", %{conn: conn} do
    conn = get conn(), page_path(conn, :sponsors)
    assert html_response(conn, 200) =~ "<h1>Sponsors</h1>"
  end

  test "GET /about-us.html", %{conn: conn} do
    conn = get conn(), page_path(conn, :about_us)
    assert html_response(conn, 200) =~ "<h1>About Us</h1>"
  end
end
