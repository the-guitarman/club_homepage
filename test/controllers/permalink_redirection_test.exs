defmodule ClubHomepage.PermalinkRedirectionTest do
  use ClubHomepage.ConnCase
  alias ClubHomepage.PermalinkRedirection

  import ClubHomepage.Factory

  setup do
    conn =
      conn()
      |> bypass_through(ClubHomepage.Router, :browser)
    {:ok, %{conn: conn}}
  end

  test "permalink found so redirect", %{conn: conn} do
    permalink = create(:permalink)
    [source_prefix, _] =
      permalink.source_path
      |> String.replace(~r{^/|/$}, "")
      |> String.split("/")
    conn = 
      conn
      |> get(permalink.source_path)
      |> PermalinkRedirection.call([String.to_atom(source_prefix)])

    assert conn.status == 301
    assert html_response(conn, 301)
    assert conn.halted
    assert redirected_to(conn, 301) =~ permalink.destination_path
  end

  test "no permalink found so don't redirect" do
    permalink = create(:permalink)
    [source_prefix, _] =
      permalink.source_path
      |> String.replace(~r{^/|/$}, "")
      |> String.split("/")
    conn = 
      conn
      |> get("/about-us.html")
      |> PermalinkRedirection.call([String.to_atom(source_prefix)])

    assert conn.status == 200
    assert html_response(conn, 200)
  end
end
