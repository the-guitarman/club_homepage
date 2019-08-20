defmodule ClubHomepage.Web.UserRole do
  @moduledoc """
  Defines, checks and validates user roles.
  """

  alias Ecto.Changeset

  @roles %{
    administrator: "user with all rights",
    member: "a registered user",
    "match-editor": "editor of matches and reporter of live match events",
    "news-editor": "author/editor of news",
    player: "an active sports man/woman",
    "team-editor": "right to edit teams",
    "text-page-editor": "author/editor of static page contents",
    "user-editor": "user administrator"
  }

  @doc """
  Returns all defined user roles.
  """
  @spec defined_roles_keys() :: [String.t]
  def defined_roles_keys do
    Map.keys(@roles)
    |> Enum.map(fn(role) -> Atom.to_string(role) end)
  end

  @doc """
  Returns a list of editable roles.
  """
  @spec editable_roles( ClubHomepage.User | Nil ) :: [String.t]
  def editable_roles(%ClubHomepage.User{} = user) do
    cond do
      has_role?(user, "administrator") ->
        defined_roles_keys()
      has_role?(user, "user-editor")   ->
        defined_roles_keys()
        |> List.delete("administrator")
      true -> []
    end
    |> delete_member_role
  end
  def editable_roles(_), do: []

  @doc """
  """
  @spec new_roles( ClubHomepage.User, [String.t], ClubHomepage.User) :: [String.t]
  def new_roles(%ClubHomepage.User{} = edited_user, new_roles, %ClubHomepage.User{} = current_user) do
    old_roles      = split(edited_user.roles)

    editable_roles = editable_roles(current_user)

    new_roles =
      new_roles
      |> Enum.drop_while(fn(new_role) -> include?(editable_roles, new_role) == false end)
      |> Enum.join(" ")
      |> clean_up_roles
      |> split

    old_roles_missing =
      old_roles
      |> Enum.filter(fn(old_role) -> not Enum.member?(new_roles, old_role) end)
      |> Enum.filter(fn(old_role) -> not Enum.member?(editable_roles, old_role) end)

    cond do
      edited_user.id == current_user.id -> new_roles
      true -> [old_roles_missing | new_roles]
    end
  end

  defp add_member_role(roles) do
    ["member" | roles] 
  end

  defp delete_member_role(roles) do
    List.delete(roles, "member")
  end

  @doc """
  Checks wether a ClubHomepage.User has a user role. Return true or false.
  """
  @spec has_role?( ClubHomepage.User | Nil, String.t | [String.t] ) :: Boolean
  @spec has_role?( Plug.Conn, String.t | [String.t] ) :: Boolean
  def has_role?(nil, _role), do: false
  def has_role?(%ClubHomepage.User{} = user, roles) when is_list(roles) do
    Enum.any?(roles, fn(role) -> has_role?(user, role) end)
  end
  def has_role?(%ClubHomepage.User{} = user, role) do
    roles = split(user.roles)
    (include?(roles, role) && valid?(role)) || include?(roles, "administrator")
  end
  def has_role?(%Plug.Conn{} = conn, roles) when is_list(roles) do
    Enum.any?(roles, fn(role) -> has_role?(conn, role) end)
  end
  def has_role?(%Plug.Conn{} = conn, role) do
    #user = get_session(conn, :current_user)
    case conn.assigns[:current_user] do
      nil -> false
      user -> has_role?(user, role)
    end
  end

  defp include?(roles, role) do
    Enum.member?(roles, role)
  end

  defp valid?(role) do
    Enum.member?(defined_roles_keys(), role)
  end



  @doc """
  Validates a ClubHomepage.User changeset. It checks that defined user roles are in the roles attribute only and it checks, that the user roles include the member role.
  """
  @spec check_roles( Ecto.Changeset.t ) :: Ecto.Changeset.t
  def check_roles(%{data: model, changes: changes} = changeset) do
    changeset
    |> check_current_roles(model)
    |> check_changes(changes)
  end

  defp check_current_roles(changeset, model) do
    case model.roles do
      nil -> Changeset.put_change(changeset, :roles, "member")
      _   -> changeset
    end
  end

  defp check_changes(changeset, changes) do
    case changes[:roles] do
      nil -> changeset
      _   -> Changeset.put_change(changeset, :roles, clean_up_roles(changes.roles))
    end
  end

  defp clean_up_roles(roles) do
    roles
    |> split
    |> Enum.filter(fn(s) -> Enum.member?(defined_roles_keys(), s) end)
    |> Enum.uniq_by(fn role -> role end)
    |> ensure_member_role_exists
    |> Enum.join(" ")
  end

  defp ensure_member_role_exists(roles) do
    case Enum.member?(roles, "member") do
      false -> add_member_role(roles)
      _     -> roles
    end
  end



  @doc """
  Splits a string of user roles into a list of strings.
  """
  @spec split( String.t ) :: [String.t]
  def split(roles) do
    roles
    |> String.split
    |> Enum.map(fn(s) -> String.trim(s) end)
  end
end
