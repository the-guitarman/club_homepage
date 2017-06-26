defmodule ClubHomepage.Web.TeamUploader do
  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:original, :normal]

  @extension_whitelist ~w(.jpg .jpeg .gif .png)

  # Whitelist file extensions:
  def validate({file, _model}) do
    file_extension = file.file_name |> Path.extname |> String.downcase
    Enum.member?(@extension_whitelist, file_extension)
  end

  # Define a thumbnail transformation:
  def transform(:normal, _) do
    # {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
    {:convert, "-strip -resize 640x480> -format png", :png}
  end

  def __storage, do: Arc.Storage.Local

  # Override the storage directory:
  def storage_dir(_version, {_file, record}) do
    uploads_path = Application.get_env(:club_homepage, :uploads)[:path]
    "#{uploads_path}/teams/#{record.id}"
  end

  # Override the persisted filenames:
  #def filename(version,  {file, scope}), do: "#{version}-#{file.file_name}"
  def filename(version, _) do
    version
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: Plug.MIME.path(file.file_name)]
  # end
end
