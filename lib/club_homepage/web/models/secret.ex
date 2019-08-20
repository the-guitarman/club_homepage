defmodule ClubHomepage.Secret do
  use ClubHomepage.Web, :model

  schema "secrets" do
    field :key, :string
    field :email, :string
    field :expires_at, :utc_datetime

    timestamps([type: :utc_datetime])
  end

  @cast_fields ~w(key email)a
  @required_fields [:key, :expires_at]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @cast_fields)
    |> check_email
    |> set_attributes
    |> validate_required(@required_fields)
  end

  defp set_attributes(changeset) do
    expires_at =
      Timex.local
      |> Timex.add(Timex.Duration.from_days(7))
      |> Timex.to_datetime()
      |> DateTime.truncate(:second)

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
