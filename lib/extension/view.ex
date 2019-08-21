defmodule ClubHomepage.Extension.View do
  alias Phoenix.HTML
  alias Phoenix.HTML.Form
  alias Phoenix.HTML.Tag

  import ClubHomepageWeb.ErrorHelpers 
  import ClubHomepageWeb.Gettext
  import ClubHomepageWeb.Localization
  import ClubHomepage.Extension.CommonTimex

  @doc """
  Returns the full club name as configured in `config/club_homepage.exs`.
  """
  @spec full_club_name() :: String
  def full_club_name do
    Application.get_env(:club_homepage, :common)[:full_club_name]
  end

  @doc """
  Returns the short club name as configured in `config/club_homepage.exs`.
  """
  @spec short_club_name() :: String
  def short_club_name do
    Application.get_env(:club_homepage, :common)[:short_club_name]
  end

  @doc """
  Extends the given asset path with a template string,
  if the asset does not exist.

  ## Example usage
  iex> ClubHomepage.Extension.View.templateable_asset_path("/favicon.ico") =~ ~r|/favicon.(template.)*ico|
  true

  iex> ClubHomepage.Extension.View.templateable_asset_path("/fav_icon.ico")
  "/fav_icon.template.ico"
  """
  @spec templateable_asset_path(String) :: String
  def templateable_asset_path(file_path) do
    case asset_path?(file_path) do
      true -> file_path
      _ ->
        extension_name = Path.extname(file_path)
        templateable_asset_path_dir_name(file_path) <> Path.basename(file_path, extension_name) <> ".template" <> extension_name
    end
  end

  defp templateable_asset_path_dir_name(file_path) do
    case Path.dirname(file_path) do
      "/" -> "/"
      dir -> dir <> "/"
    end
  end

  @doc """
  Checks wether the given asset path exists.

  ## Example usage
  iex> if File.exists?(ClubHomepage.Extension.View.absolute_asset_path("/favicon.ico")) do
  ...>   ClubHomepage.Extension.View.asset_path?("/favicon.ico") == true
  ...> else
  ...>   ClubHomepage.Extension.View.asset_path?("/favicon.ico") == false
  ...> end
  true

  iex> ClubHomepage.Extension.View.asset_path?("/fav_icon.ico")
  false
  """
  @spec asset_path?(String) :: Boolean
  def asset_path?(file_path) do
    File.exists?(absolute_asset_path(file_path))
  end

  @doc """
  Return the absolute/full path to the asset.

  ## Example usage
  iex> ClubHomepage.Extension.View.absolute_asset_path("/favicon.ico") =~ ~r|club_homepage/priv/static/favicon.ico$|
  true
  """
  @spec absolute_asset_path(String) :: String
  def absolute_asset_path(file_path) do
    Path.join([
      Application.app_dir(:club_homepage, "priv"),
      "static",
      file_path
    ])
  end




  def current_link(_conn, _module, [] = actions) when is_list(actions), do: ""
  def current_link(conn, module, [head | tail] = actions) when is_list(actions) do
    current_link_class(conn, module, head) <> " " <> current_link(conn, module, tail)
  end

  def current_link(conn, module, action) when is_atom(action) do
    current_link_class(conn, module, action)
  end

  def current_link(conn, module, action) when is_bitstring(action) do
    current_link_class(conn, module, String.to_atom(action))
  end

  defp current_link_class(conn, module, action) do
    case Phoenix.Controller.controller_module(conn) == module && Phoenix.Controller.action_name(conn) == action do
      true -> "active"
      _ -> ""
    end
  end




  def copyright do
    start_year = 2016
    %{year: current_year} = Timex.now
    year = 
      cond do
        start_year == current_year -> "#{start_year}"
        true -> "#{start_year} - #{current_year}"
      end
    "© Copyright #{year}"
  end

  def current_domain(conn) do
    case conn.port do
      80 -> conn.host
      _ -> "#{conn.host}:#{conn.port}"
    end
  end




  def js_date_input_format(divider \\ ".") do
    date_format()
    |> String.replace("%", "")
    |> String.split(divider)
    |> Enum.map(fn(el) -> if el == "Y", do: "#{el}#{el}#{el}#{el}", else: "#{el}#{el}"
    |> String.upcase() end)
    |> Enum.join(divider)
  end

  def timex_date_input(form, field, opts \\ []) do
    opts = Keyword.put(opts, :"data-format", js_date_input_format())
    timex_input(form, field, date_format(), opts)
  end

  def js_time_input_format(divider \\ ":") do
    parts = 
      time_format()
      |> String.replace("%", "")
      |> String.split(divider)
      |> Enum.map(fn(el) -> String.upcase("#{el}#{el}") end)

    [String.upcase(List.first(parts)), String.downcase(List.last(parts))]
    |> Enum.join(divider)
  end

  def timex_datetime_input_format do
    "#{date_format()} #{time_format()}"
  end

  def js_datetime_input_format do
    "#{js_date_input_format()} #{js_time_input_format()}"
  end

  def timex_datetime_input(form, field, opts \\ []) do
    opts = Keyword.put(opts, :"data-format", js_datetime_input_format())
    timex_input(form, field, timex_datetime_input_format(), opts)
  end

  defp timex_input(%{data: model, params: params} = form, field, format, opts) do
    field_name = Atom.to_string(field)
    form = 
      case Map.fetch(params, field_name) do
        {:ok, nil} ->
          form
        {:ok, timex_datetime} ->
          date_string =
            timex_datetime
            |> Timex.local
            |> timex_datetime_to_string(format)
          params = Map.put(params, field_name, date_string)
          Map.put(form, :params, params)
        :error ->
          case Map.get(model, field) do
            nil -> form
            timex_datetime -> 
              date_string =
                timex_datetime
                |> Timex.local
                |> timex_datetime_to_string(format)
              params = Map.put(params, field_name, date_string)
              Map.put(form, :params, params)
          end
      end
    field_css_class =
      case String.contains?(format, ["%H", "%M"]) do
        true -> "datetime"
        false -> "date"
      end
    Tag.content_tag(:div, class: "input-group #{field_css_class}") do
      button = Tag.content_tag(:span, class: "input-group-addon") do
        Tag.content_tag(:i, "", class: "glyphicon glyphicon-calendar")
      end
      HTML.raw(HTML.safe_to_string(Form.text_input(form, field, opts)) <> HTML.safe_to_string(button))
    end
  end
  defp timex_input(%{model: model, params: params}, field, format, opts) do
    timex_input(%{data: model, params: params}, field, format, opts)
  end

  def show_form_errors(changeset, f) do
    if changeset.action do
      Tag.content_tag(:div, class: "alert alert-danger") do
        p_tag = Tag.content_tag(:p) do
          gettext("form_input_errors_notice")
        end
        ul_tag = Tag.content_tag(:ul) do
          for {attr, message} <- f.errors do
            Tag.content_tag(:li) do
              Gettext.dgettext(ClubHomepageWeb.Gettext, "models", attr_underscored(attr)) <> " " <> translate_error(message)
            end
          end
        end
        HTML.raw(HTML.safe_to_string(p_tag) <> HTML.safe_to_string(ul_tag))
      end
    end
  end

  def required_field(form, field) do
    case form.data.__struct__.required_field?(field) do
      true  -> " *"
      false -> ""
    end
  end

  def uploader_image_tag(module, model, version) do
    Tag.tag :img, src: uploader_image_source(module, model, version), alt: uploader_image_tag_alt(model, version)
  end

  def uploader_image_source(module, model, version) do
    module.url({model.attachment, model}, version)
  end

  defp uploader_image_tag_alt(model, version) do
    name = 
      case Map.fetch(model, :name) do
        :error -> ""
        {:ok, name} -> name
      end
    "#{version} #{name}"
  end

  def number_field(form, field, options \\ []) do
    changeset = form.source
    Tag.content_tag(:div, class: "js-number-field css-number-field form-group #{error_cls(changeset, form, field)}") do
      # label @f, :title, gettext("number_of_units"), class: "control-label"
      Tag.content_tag(:div, class: "input-group") do
        e1 = Tag.content_tag(:div, class: "input-group-addon btn btn-primary") do
          Tag.content_tag(:span, class: "glyphicon glyphicon-minus") do
          end
        end
        options =
          options
          |> Keyword.put(:class, "form-control text-center no-spin")
          |> Keyword.put(:placeholder, Gettext.gettext(ClubHomepageWeb.Gettext, Atom.to_string(field)))
        e2 = Form.number_input form, field, options
        e3 = Tag.content_tag(:div, class: "input-group-addon btn btn-primary") do
          Tag.content_tag(:span, class: "glyphicon glyphicon-plus") do
          end
        end
        [e1, e2, e3]
      end
    end
  end
end
