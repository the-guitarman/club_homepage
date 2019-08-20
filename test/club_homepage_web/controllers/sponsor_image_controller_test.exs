defmodule ClubHomepage.SponsorImageControllerTest do
  use ClubHomepage.Web.ConnCase

  alias ClubHomepage.SponsorImage

  import ClubHomepage.Factory

  @file_name "test/support/images/test_image.jpg"
  @valid_attrs %{
    attachment: %Plug.Upload{content_type: "image/jpeg", filename: "test_image.jpg", path: @file_name},
    name: "test image"
  }
  @invalid_attrs %{name: ""}

  setup_all do
    uploads_path = Application.get_env(:club_homepage, :uploads)[:path]
    File.mkdir_p(uploads_path)

    on_exit fn ->
      File.rm_rf(uploads_path)
    end
  end

  setup context do
    conn = build_conn()
    if context[:login] do
      current_user = insert(:user)
      conn = assign(conn, :current_user, current_user)
      {:ok, conn: conn, current_user: current_user}
    else
      {:ok, conn: conn}
    end
  end

  @tag login: false
  test "requires user authentication on all actions", %{conn: conn} do
    sponsor_image = insert(:sponsor_image)
    Enum.each([
      get(conn, sponsor_image_path(conn, :index)),
      get(conn, sponsor_image_path(conn, :new)),
      post(conn, sponsor_image_path(conn, :create), sponsor_image: @valid_attrs),
      post(conn, sponsor_image_path(conn, :create), sponsor_image: @invalid_attrs),
      get(conn, sponsor_image_path(conn, :edit, sponsor_image)),
      put(conn, sponsor_image_path(conn, :update, sponsor_image), sponsor_image: @valid_attrs),
      put(conn, sponsor_image_path(conn, :update, sponsor_image), sponsor_image: @invalid_attrs),
      delete(conn, sponsor_image_path(conn, :delete, sponsor_image))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, sponsor_image_path(conn, :index)
    assert html_response(conn, 200) =~ "<h2>All Sponsor Images</h2>"
  end

  @tag login: true
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, sponsor_image_path(conn, :new)
    assert html_response(conn, 200) =~ "Create Sponsor Image"
  end

  @tag login: true
  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, sponsor_image_path(conn, :create), sponsor_image: @valid_attrs
    sponsor_image_id = get_highest_id(SponsorImage)
    assert redirected_to(conn) == sponsor_image_path(conn, :index) <> "#sponsor-image-#{sponsor_image_id}"
    assert Repo.get!(SponsorImage, sponsor_image_id)

    sponsor_image = Repo.get!(SponsorImage, sponsor_image_id)

    for {_version, web_path} <- ClubHomepage.Web.SponsorUploader.urls({sponsor_image.attachment, sponsor_image}) do
      [path, _] = String.split(web_path, "?")
      path = remove_trailing_slash(path)
      assert File.exists?(Path.expand(path))
    end
  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, sponsor_image_path(conn, :create), sponsor_image: @invalid_attrs
    assert html_response(conn, 200) =~ "Create Sponsor Image"
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn} do
    sponsor_image = insert(:sponsor_image)
    conn = get conn, sponsor_image_path(conn, :edit, sponsor_image)
    assert html_response(conn, 200) =~ "Edit Sponsor Image"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    sponsor_image = insert(:sponsor_image)
    conn = put conn, sponsor_image_path(conn, :update, sponsor_image), sponsor_image: @valid_attrs
    assert redirected_to(conn) == sponsor_image_path(conn, :index) <> "#sponsor-image-#{sponsor_image.id}"
    assert Repo.get!(SponsorImage, sponsor_image.id)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    sponsor_image = insert(:sponsor_image)
    conn = put conn, sponsor_image_path(conn, :update, sponsor_image), sponsor_image: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Sponsor Image"
  end

  @tag login: true
  test "deletes chosen resource", %{conn: conn} do
    sponsor_image = insert(:sponsor_image)

    destination_path = ClubHomepage.Web.SponsorUploader.storage_dir(nil, {nil, sponsor_image})
    File.mkdir_p!(destination_path)

    web_paths = ClubHomepage.Web.SponsorUploader.urls({sponsor_image.attachment, sponsor_image})

    for {_version, web_path} <- web_paths do
      [path, _query_string] = String.split(web_path, "?")
      path = remove_trailing_slash(path)
      File.cp(@file_name, path)
      assert File.exists?(path)
    end

    conn = delete conn, sponsor_image_path(conn, :delete, sponsor_image)

    assert redirected_to(conn) == sponsor_image_path(conn, :index)
    refute Repo.get(SponsorImage, sponsor_image.id)
    for {_version, web_path} <- web_paths do
      [path, _query_string] = String.split(web_path, "?")
      File.mkdir_p(Path.dirname(path))
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
