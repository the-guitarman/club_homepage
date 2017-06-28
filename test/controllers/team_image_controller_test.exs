defmodule ClubHomepage.TeamImageControllerTest do
  use ClubHomepage.Web.ConnCase

  alias ClubHomepage.Team
  alias ClubHomepage.TeamImage

  import ClubHomepage.Factory

  @file_name "test/support/images/test_image.jpg"
  @valid_attrs %{
    team_id: 0,
    year: 2016,
    attachment: %Plug.Upload{content_type: "image/jpeg", filename: "test_image.jpg", path: @file_name},
    description: "test description"
  }
  @invalid_attrs %{team_id: 0, year: ""}

  setup_all do
    uploads_path = Application.get_env(:club_homepage, :uploads)[:path]
    File.mkdir_p(uploads_path)

    on_exit fn ->
      File.rm_rf(uploads_path)
    end
  end

  setup context do
    conn = build_conn()
    team_image = insert(:team_image)
    valid_attrs = %{@valid_attrs | team_id: team_image.team_id}
    if context[:login] do
      current_user = insert(:user)
      conn = assign(conn, :current_user, current_user)
      {:ok, conn: conn, current_user: current_user, valid_attrs: valid_attrs}
    else
      {:ok, conn: conn, valid_attrs: valid_attrs}
    end
  end

  @tag login: false
  test "requires user authentication on all actions", %{conn: conn, valid_attrs: valid_attrs} do
    team_image = insert(:team_image)
    Enum.each([
      get(conn, team_image_path(conn, :index)),
      get(conn, team_image_path(conn, :new)),
      post(conn, team_image_path(conn, :create), team_image: valid_attrs),
      post(conn, team_image_path(conn, :create), team_image: @invalid_attrs),
      get(conn, team_image_path(conn, :edit, team_image)),
      put(conn, team_image_path(conn, :update, team_image), team_image: valid_attrs),
      put(conn, team_image_path(conn, :update, team_image), team_image: @invalid_attrs),
      delete(conn, team_image_path(conn, :delete, team_image))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, team_image_path(conn, :index)
    assert html_response(conn, 200) =~ "<h2>All Team Images</h2>"
  end

  @tag login: true
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, team_image_path(conn, :new)
    assert html_response(conn, 200) =~ "<h2>New Team Image</h2>"
  end

  @tag login: true
  test "creates resource and redirects when data is valid", %{conn: conn, valid_attrs: valid_attrs} do
    conn = post conn, team_image_path(conn, :create), team_image: valid_attrs
    team_image_id = get_highest_id(TeamImage)
    team_image = Repo.get!(TeamImage, team_image_id)
    team = Repo.get!(Team, team_image.team_id)
    assert redirected_to(conn) == team_images_page_path(conn, :show_images, team.slug)
    for {_version, web_path} <- ClubHomepage.Web.TeamUploader.urls({team_image.attachment, team_image}) do
      [path, _] = String.split(web_path, "?")
      path = remove_trailing_slash(path)
      assert File.exists?(Path.expand(path))
    end
  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, team_image_path(conn, :create), team_image: @invalid_attrs
    assert html_response(conn, 200) =~ "<h2>New Team Image</h2>"
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn} do
    team_image = insert(:team_image)
    conn = get conn, team_image_path(conn, :edit, team_image)
    assert html_response(conn, 200) =~ "<h2>Edit Team Image</h2>"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn, valid_attrs: valid_attrs} do
    team_image = insert(:team_image)
    team = Repo.get!(Team, team_image.team_id)
    valid_attrs = %{valid_attrs | team_id: team_image.team_id}
    conn = put conn, team_image_path(conn, :update, team_image), team_image: valid_attrs
    assert redirected_to(conn) == team_images_page_path(conn, :show_images, team.slug)
    assert Repo.get!(TeamImage, team_image.id)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    team_image = insert(:team_image)
    conn = put conn, team_image_path(conn, :update, team_image), team_image: @invalid_attrs
    assert html_response(conn, 200) =~ "<h2>Edit Team Image</h2>"
  end

  @tag login: true
  test "creates and deletes chosen resource", %{conn: conn} do
    team_image = insert(:team_image)
    team = Repo.get!(Team, team_image.team_id)

    destination_path = ClubHomepage.Web.TeamUploader.storage_dir(nil, {nil, team_image})
    File.mkdir_p!(destination_path)

    web_paths = ClubHomepage.Web.TeamUploader.urls({team_image.attachment, team_image})

    for {_version, web_path} <- web_paths do
      [path, _query_string] = String.split(web_path, "?")
      path = remove_trailing_slash(path)
      File.cp_r(@file_name, path)
      assert File.exists?(path)
    end

    conn = delete conn, team_image_path(conn, :delete, team_image)

    assert redirected_to(conn) == team_images_page_path(conn, :show_images, team.slug)
    refute Repo.get(TeamImage, team_image.id)
    for {_version, web_path} <- web_paths do
      [path, _query_string] = String.split(web_path, "?")
      path = remove_trailing_slash(path)
      refute File.exists?(path)
    end

    File.rm_rf!(destination_path)
  end

  defp remove_trailing_slash(path) do
    path
    |> String.split("/")
    |> Enum.filter(fn(el) -> String.length(el) > 0 end)
    |> Enum.join("/")
  end
end
