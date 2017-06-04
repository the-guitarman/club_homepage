defmodule ClubHomepage.Season do
  use ClubHomepage.Web, :model

  schema "seasons" do
    field :name, :string

    has_many :matches, ClubHomepage.Match#, on_delete: :delete_all

    timestamps()
  end

  @required_fields ~w(name)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:name, ~r/\A20\d\d-20\d\d\z/i)
  end
end
