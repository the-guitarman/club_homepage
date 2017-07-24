defmodule ClubHomepage.Web.NewsController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.News

  plug :is_news_editor when action in [:show, :new, :create, :edit, :update, :delete]
  plug :scrub_params, "news" when action in [:create, :update]

  def index(conn, _params) do
    query = from(n in News, order_by: [desc: n.updated_at])
    query =
      case ClubHomepage.Web.Auth.logged_in?(conn, %{}) do
        true -> query
        false -> from(n in query, where: n.public == true)
      end
    news = Repo.all(query)
    render(conn, "index.html", news: news)
  end

  def new(conn, _params) do
    changeset = News.changeset(%News{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"news" => news_params}) do
    changeset = News.changeset(%News{}, news_params)

    case Repo.insert(changeset) do
      {:ok, _news} ->
        conn
        |> put_flash(:info, gettext("news_created_successfully"))
        |> redirect(to: news_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    news = Repo.get!(News, id)
    render(conn, "show.html", news: news)
  end

  def edit(conn, %{"id" => id}) do
    news = Repo.get!(News, id)
    changeset = News.changeset(news)
    render(conn, "edit.html", news: news, changeset: changeset)
  end

  def update(conn, %{"id" => id, "news" => news_params}) do
    news = Repo.get!(News, id)
    changeset = News.changeset(news, news_params)

    case Repo.update(changeset) do
      {:ok, news} ->
        conn
        |> put_flash(:info, gettext("news_updated_successfully"))
        |> redirect(to: news_path(conn, :index) <> "#news-#{news.id}")
      {:error, changeset} ->
        render(conn, "edit.html", news: news, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    news = Repo.get!(News, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(news)

    conn
    |> put_flash(:info, gettext("news_deleted_successfully"))
    |> redirect(to: news_path(conn, :index))
  end
end
