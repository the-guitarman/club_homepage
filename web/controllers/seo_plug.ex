defmodule ClubHomepage.SEO.Plug do
  import Plug.Conn
  import ClubHomepage.Extension.Controller, only: [full_club_name: 0]

  def put_seo(%{private: %{phoenix_action: action_name, phoenix_controller: controller}} = conn, _options) do
    controller_name = extract_controller_name(controller)
    settings = apply(__MODULE__, controller_name, [controller, action_name]) || []

    conn
    |> assign(:title, settings[:title])
    |> assign(:meta, settings[:meta])
  end

  def page_controller(controller, action_name) do
    %{
      index: %{
        title: "#{full_club_name} - Homepage",
        meta: """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam feugiat 
        nibh ligula. Maecenas egestas nibh cursus erat sodales, vitae congue nisi
        tempus. Nam mattis et velit eu lacinia.
        """
             },
      contact: %{
        title: "Contact Us",
        meta: "..."
      }
    }[action_name]
  end

  defp extract_controller_name(controller) do
    controller
    |> Atom.to_string
    |> String.split(".")
    |> List.last
    |> Macro.underscore
    |> String.to_atom
  end
end
