defmodule ClubHomepage.Extension.CommonTestExtension do
  alias ClubHomepage.Repo
  import Ecto.Query, only: [from: 2]

  def get_highest_id(module) do
    query = from t in module, select: max(t.id)
    case Repo.all(query) do
      [nil] -> 0
      [id]  -> id
    end
  end
end
