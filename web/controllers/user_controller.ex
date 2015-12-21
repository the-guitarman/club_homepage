defmodule ClubHomepage.UserController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.User
  alias ClubHomepage.Auth

  plug :scrub_params, "user" when action in [:create, :update]

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def new(conn, params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset, secret: params["secret"])
  end

  def create(conn, %{"user" => user_params}) do
    user_params = parse_date_field(user_params, :birthday)

    secret_key = user_params["secret"]
    changeset = 
      User.changeset(%User{}, user_params)
      |> ClubHomepage.SecretCheck.run(secret_key)

    case Repo.insert(changeset) do
      {:ok, user} ->
        ClubHomepage.SecretCheck.delete(secret_key)
        conn
        |> Auth.login(user)
        |> put_flash(:info, "Dein Benutzer wurde erfolgreich angelegt und eingeloggt.")
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, secret: secret_key)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.html", user: user)
  end

  # def edit(conn, %{"id" => id}) do
  #   user = Repo.get!(User, id)
  #   changeset = User.changeset(user)
  #   render(conn, "edit.html", user: user, changeset: changeset)
  # end

  # def update(conn, %{"id" => id, "user" => user_params}) do
  #   user = Repo.get!(User, id)
  #   changeset = User.changeset(user, user_params)

  #   case Repo.update(changeset) do
  #     {:ok, user} ->
  #       conn
  #       |> put_flash(:info, "User updated successfully.")
  #       |> redirect(to: user_path(conn, :show, user))
  #     {:error, changeset} ->
  #       render(conn, "edit.html", user: user, changeset: changeset)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   user = Repo.get!(User, id)

  #   # Here we use delete! (with a bang) because we expect
  #   # it to always work (and if it does not, it will raise).
  #   Repo.delete!(user)

  #   conn
  #   |> put_flash(:info, "User deleted successfully.")
  #   |> redirect(to: user_path(conn, :index))
  # end
end
