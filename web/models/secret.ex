defmodule ClubHomepage.Secret do
  use ClubHomepage.Web, :model

  schema "secrets" do
    field :key, :string
    field :email, :string
    field :expires_at, Timex.Ecto.DateTime

    timestamps
  end

  @required_fields ~w()
  @optional_fields ~w(key email)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> check_email
    |> set_attributes
  end

  defp set_attributes(changeset) do
    expires_at = 
      Timex.DateTime.local
      |> Timex.add(Timex.Time.to_timestamp(7, :days))

    changeset
    |> put_change(:key, SecureRandom.urlsafe_base64)
    |> put_change(:expires_at, expires_at)
  end

  defp check_email(changeset) do
    case get_field(changeset, :email) do
      "" -> changeset
      nil -> changeset
      _ -> 
        changeset
        |> validate_format(:email, ~r/\A[A-Z0-9_\.&%\+\-\']+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,13})\z/i)
        |> update_change(:email, &String.downcase/1)
    end
  end
end
