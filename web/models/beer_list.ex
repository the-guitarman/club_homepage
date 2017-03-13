defmodule ClubHomepage.BeerList do
  use ClubHomepage.Web, :model

  schema "beer_lists" do
    belongs_to :user, ClubHomepage.User
    belongs_to :deputy, ClubHomepage.Deputy

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> validate_required([])
  end
end
