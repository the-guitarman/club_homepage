defmodule ClubHomepage.MeetingPoint do
  use ClubHomepage.Web, :model

  #alias ClubHomepage.Web.ModelValidator

  schema "meeting_points" do
    belongs_to :address, ClubHomepage.Address
    has_many :matches, ClubHomepage.Match#, on_delete: :delete_all

    field :name, :string

    timestamps()
  end

  @cast_fields ~w(address_id name)
  @required_fields [:address_id]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:address_id)
    |> unique_constraint(:address_id)
    #|> ModelValidator.foreign_key_constraint(:address_id)
    #|> ModelValidator.validate_uniqueness(:address_id)
  end
end
