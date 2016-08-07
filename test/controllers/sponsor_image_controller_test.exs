defmodule ClubHomepage.SponsorImageControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.SponsorImage

  import ClubHomepage.Factory

  @valid_attrs %{
    # attachment: %Plug.Upload{
    #   content_type: "image/jpg",
    #   filename: "test_image.jpg",
    #   path: "test/support/images/test_image.jpg"
    # }, 
    # attachment: %{
    #   file_name: "test/support/images/test_image.jpg",
    #   updated_at: Ecto.DateTime.utc
    # },
    attachment: "test/support/images/test_image.jpg",
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
      current_user = create(:user)
      conn = assign(conn, :current_user, current_user)
      {:ok, conn: conn, current_user: current_user}
    else
      {:ok, conn: conn}
    end
  end

  @tag login: false
  test "requires user authentication on all actions", %{conn: conn} do
    sponsor_image = create(:sponsor_image)
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
    sponsor_image_id = maximum_id()
    assert redirected_to(conn) == sponsor_image_path(conn, :index) <> "#sponsor-image-#{sponsor_image_id}"
    assert Repo.get!(SponsorImage, sponsor_image_id)

    # TODO: check files


  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, sponsor_image_path(conn, :create), sponsor_image: @invalid_attrs
    assert html_response(conn, 200) =~ "Create Sponsor Image"
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn} do
    sponsor_image = create(:sponsor_image)
    conn = get conn, sponsor_image_path(conn, :edit, sponsor_image)
    assert html_response(conn, 200) =~ "Edit Sponsor Image"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    sponsor_image = create(:sponsor_image)
    conn = put conn, sponsor_image_path(conn, :update, sponsor_image), sponsor_image: @valid_attrs
    assert redirected_to(conn) == sponsor_image_path(conn, :index) <> "#sponsor-image-#{sponsor_image.id}"
    assert Repo.get!(SponsorImage, sponsor_image.id)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    sponsor_image = create(:sponsor_image)
    conn = put conn, sponsor_image_path(conn, :update, sponsor_image), sponsor_image: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Sponsor Image"
  end

  @tag login: true
  test "deletes chosen resource", %{conn: conn} do
    sponsor_image = create(:sponsor_image)
    conn = delete conn, sponsor_image_path(conn, :delete, sponsor_image)
    assert redirected_to(conn) == sponsor_image_path(conn, :index)
    refute Repo.get(SponsorImage, sponsor_image.id)
  end

  defp maximum_id do
    query = from t in SponsorImage, select: max(t.id)
    case ClubHomepage.Repo.all(query) do
      [nil] -> 0
      [id]  -> id
    end
  end
end
