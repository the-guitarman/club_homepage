defmodule ClubHomepage.OpponentTeam do
  use ClubHomepage.Web, :model

  schema "opponent_teams" do
    field :name, :string

    belongs_to :address, ClubHomepage.Address
    has_many :matches, ClubHomepage.Match, on_delete: :delete_all

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
