defmodule UcxChat.Config.FileUpload do
  use UcxChat.Web, :model

  embedded_schema do
    field :file_uploads_enabled, :boolean, default: true
    field :maximum_file_upload_size_kb, :integer, default: 2000
    field :accepted_media_types, :string, default: "image/*,audio/*,video/*,application/zip,application/x-rar-compressed,application/pdf,text/plain,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    field :protect_upload_files, :boolean, default: true
    field :storage_system, :string, default: "FileSystem"
    field :dm_file_uploads, :boolean, default: true

    field :s3_bucket_name, :string, default: ""
    field :s3_acl, :string, default: ""
    field :s3_aws_access_key_id, :string, default: ""
    field :s3_aws_secret_access_key, :string, default: ""
    field :s3_cdn_domain_for_downloads, :string, default: ""
    field :s3_region, :string, default: ""
    field :s3_bucket_url, :string, default: ""
    field :urls_expiration_timespan, :integer, default: 120

    field :system_path, :string, default: "/var/ucx_chat/uploads"
  end

  @fields [
    :file_uploads_enabled, :maximum_file_upload_size_kb,
    :accepted_media_types, :protect_upload_files,
    :storage_system, :dm_file_uploads,
    :s3_bucket_name, :s3_acl, :s3_aws_access_key_id,
    :s3_aws_secret_access_key, :s3_cdn_domain_for_downloads,
    :s3_region, :s3_bucket_url, :urls_expiration_timespan,
    :system_path,
  ]

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
  end
end
