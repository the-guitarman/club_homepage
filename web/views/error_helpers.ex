defmodule ClubHomepage.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """
  use Phoenix.HTML

  @doc """
  Generates error css class for container element of inlined form input errors.
  """
  def error_cls(form, field) do
    if form.errors[field] do
      "has-error"
    else
      ""
    end
  end
  def error_cls(changeset, form, field) do
    if changeset.action do
      error_cls(form, field)
    else
      "" 
    end
  end

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    if error = form.errors[field] do
      field_translated = Gettext.dgettext(ClubHomepage.Gettext, "models", attr_underscored(field))
      content_tag :span, (field_translated <> " " <> translate_error(error)), class: "help-block"
      # content_tag :span, (humanize(field) <> " " <> translate_error(error)), class: "help-block"
    end
  end
  def error_tag(changeset, form, field) do
    if changeset.action do
      error_tag(form, field)
    end
  end

  def attr_underscored(attr) do
    attr
    |> humanize
    |> String.downcase
    |> String.replace(~r/\s/, "_")
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # Because error messages were defined within Ecto, we must
    # call the Gettext module passing our Gettext backend. We
    # also use the "errors" domain as translations are placed
    # in the errors.po file.
    # Ecto will pass the :count keyword if the error message is
    # meant to be pluralized.
    # On your own code and templates, depending on whether you
    # need the message to be pluralized or not, this could be
    # written simply as:
    #
    #     dngettext "errors", "1 file", "%{count} files", count
    #     dgettext "errors", "is invalid"
    #
    if count = opts[:count] do
      Gettext.dngettext(MyApp.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(MyApp.Gettext, "errors", msg, opts)
    end
  end
end
