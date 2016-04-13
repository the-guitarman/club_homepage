defmodule ClubHomepage.MeetingPointController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.MeetingPoint

  plug :is_match_editor?
  plug :scrub_params, "meeting_point" when action in [:create, :update]
  plug :get_address_select_options when action in [:new, :create, :edit, :update]

  def index(conn, _params) do
    meeting_points = Repo.all(from(mp in MeetingPoint, preload: [:address]))
    render(conn, "index.html", meeting_points: meeting_points)
  end

  def new(conn, _params) do
    changeset = MeetingPoint.changeset(%MeetingPoint{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"meeting_point" => meeting_point_params}) do
    changeset = MeetingPoint.changeset(%MeetingPoint{}, meeting_point_params)

    case Repo.insert(changeset) do
      {:ok, _meeting_point} ->
        conn
        |> put_flash(:info, "Meeting point created successfully.")
        |> redirect(to: meeting_point_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    meeting_point = Repo.get!(MeetingPoint, id)
    render(conn, "show.html", meeting_point: meeting_point)
  end

  def edit(conn, %{"id" => id}) do
    meeting_point = Repo.get!(MeetingPoint, id)
    changeset = MeetingPoint.changeset(meeting_point)
    render(conn, "edit.html", meeting_point: meeting_point, changeset: changeset)
  end

  def update(conn, %{"id" => id, "meeting_point" => meeting_point_params}) do
    meeting_point = Repo.get!(MeetingPoint, id)
    changeset = MeetingPoint.changeset(meeting_point, meeting_point_params)

    case Repo.update(changeset) do
      {:ok, meeting_point} ->
        conn
        |> put_flash(:info, "Meeting point updated successfully.")
        |> redirect(to: meeting_point_path(conn, :show, meeting_point))
      {:error, changeset} ->
        render(conn, "edit.html", meeting_point: meeting_point, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    meeting_point = Repo.get!(MeetingPoint, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(meeting_point)

    conn
    |> put_flash(:info, "Meeting point deleted successfully.")
    |> redirect(to: meeting_point_path(conn, :index))
  end

  defp get_address_select_options(conn, _) do
    query = from(s in ClubHomepage.Address,
                 select: {[s.street, ", ", s.zip_code, " ", s.city], s.id},
                 order_by: [desc: s.street])
    assign(conn, :address_options, Repo.all(query))
  end
end
