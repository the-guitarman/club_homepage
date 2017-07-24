defmodule ClubHomepage.PermalinkRedirectionTest do
  use ClubHomepage.Web.ConnCase

  import ClubHomepage.Factory

  setup do
    conn = build_conn()
    {:ok, %{conn: conn}}
  end

  test "permalink found so redirect", %{conn: conn} do
    permalink = insert(:permalink)

    conn = 
      conn
      |> get(permalink.source_path)

    assert conn.status == 301
    assert html_response(conn, 301)
    assert conn.halted
    assert redirected_to(conn, 301) =~ permalink.destination_path
  end

  test "no permalink found so don't redirect", %{conn: conn} do
    conn = 
      conn
      |> get("/about-us.html")

    assert conn.status == 200
    assert html_response(conn, 200)
  end
end
