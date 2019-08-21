defmodule ClubHomepage.TextPage do
  use ClubHomepageWeb, :model

  #alias ClubHomepageWeb.ModelValidator

  schema "text_pages" do
    field :key, :string
    field :text, :string

    timestamps([type: :utc_datetime])
  end

  @cast_fields [:key, :text]
  @required_fields [:key]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:key)
    #|> ModelValidator.validate_uniqueness(:key)
  end
end
