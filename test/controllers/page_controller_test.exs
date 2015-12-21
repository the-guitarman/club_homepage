defmodule ClubHomepage.PageControllerTest do
  use ClubHomepage.ConnCase

  import Ecto.Query, only: [from: 2]

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "GET /", %{conn: conn} do
    conn = get conn(), page_path(conn, :index)
    assert html_response(conn, 200) =~ "<h2>Aktuelles</h2>"
    assert html_response(conn, 200) =~ "<h2>Ergebnisse</h2>"

    query = from t in ClubHomepage.Team, select: count(t.id)
    [team_count] = ClubHomepage.Repo.all(query)
    if team_count > 2 do
      assert html_response(conn, 200) =~ "<h2>Mannschaften</h2>"
    else
      refute html_response(conn, 200) =~ "<h2>Mannschaften</h2>"
    end
  end

  test "GET /impressum.html", %{conn: conn} do
    conn = get conn(), page_path(conn, :impressum)
    assert html_response(conn, 200) =~ "<h1>Impressum</h1>"
  end
end
