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
    |> cast(params, ~w(title user_id price_per_beer), ~w(deputy_id))
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:deputy_id)
    |> validate_required([:title, :price_per_beer])
    |> validate_number(:price_per_beer, greater_than: 0)
  end
end
