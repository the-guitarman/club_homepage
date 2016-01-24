defmodule ClubHomepage.MeetingPoint do
  use ClubHomepage.Web, :model

  alias ClubHomepage.ModelValidator

  schema "meeting_points" do
    belongs_to :address, ClubHomepage.Address
    has_many :matches, ClubHomepage.Match, on_delete: :delete_all

    field :name, :string

    timestamps
  end

  @required_fields ~w(address_id)
  @optional_fields ~w(name)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:address_id)
    |> ModelValidator.validate_uniqueness(:address_id, message: "ist bereits vergeben")
  end
end
