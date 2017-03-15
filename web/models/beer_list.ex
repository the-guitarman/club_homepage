defmodule ClubHomepage.BeerList do
  use ClubHomepage.Web, :model

  schema "beer_lists" do
    belongs_to :user, ClubHomepage.User
    belongs_to :deputy, ClubHomepage.Deputy

    field :title, :string
    field :price_per_beer, :float

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(title price_per_beer))
    |> validate_required([:title, :price_per_beer])
  end
end
