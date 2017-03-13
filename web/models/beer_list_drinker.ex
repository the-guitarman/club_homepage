defmodule ClubHomepage.BeerListDrinker do
  use ClubHomepage.Web, :model

  schema "beer_list_drinkers" do
    field :beers, :integer
    belongs_to :beer_list, ClubHomepage.BeerList
    belongs_to :user, ClubHomepage.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:beers])
    |> validate_required([:beers])
  end
end
