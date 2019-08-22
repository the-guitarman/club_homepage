defmodule ClubHomepageWeb.AuthByRole.Helper do
  @doc """
  Returns the plug function name for a given user role key. This is used to generate one plug function and test methods for each user role key. 
  """
  @spec plug_function_name(String.t) :: Atom.t
  def plug_function_name(user_role_key) do
    "is_#{String.replace(user_role_key, "-", "_")}"
    |> String.to_atom()
  end
end
