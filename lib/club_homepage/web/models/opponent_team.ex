defmodule ClubHomepage.OpponentTeam do
  use ClubHomepage.Web, :model

  #alias ClubHomepage.Web.ModelValidator

  schema "opponent_teams" do
    field :name, :string

    belongs_to :address, ClubHomepage.Address
    has_many :matches, ClubHomepage.Match#, on_delete: :delete_all

    timestamps()
  end

  @required_fields ~w(name)
  @optional_fields ~w(address_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:name)
    #|> ModelValidator.validate_uniqueness(:name)
  end
end
