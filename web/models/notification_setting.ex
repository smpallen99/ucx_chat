defmodule UcxChat.NotificationSetting do
  use UcxChat.Web, :model

  embedded_schema do
    field :audio, :string, default: "system_default"
    field :desktop, :string, default: "mentions"
    field :duration, :integer, default: nil
    field :mobile, :string, default: "mentions"
    field :email, :string, default: "preferences"
    field :unread_alert, :string, default: "preferences"
  end

  @fields [
    :audio, :desktop, :duration, :mobile, :email, :unread_alert
  ]

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    # |> validate_required(@fields)
  end

  def option_text(options, name) do
    options
    |> Enum.into(%{})
    |> Map.get(name)
  end

  def options(:audio), do: [
    {"none", "None"},
    {"system_default", "Use account preferences (Default)"},
    {"chime", "Chime"},
    {"beep", "Beep"},
    {"chelle", "Chelle"},
    {"ding", "Ding"},
    {"droplet", "Droplet"},
    {"highbell", "Highbell"},
    {"seasons", "Seasons"}
  ]

  def options(field) when field in ~w(desktop mobile)a, do: [
    {"all", "All messages"},
    {"mentions", "Mentions (default)"},
    {"nothing", "Nothing"}
  ]

  def options(:email), do: [
    {"all", "All messages"},
    {"nothing", "Nothing"},
    {"preferences", "Use account preference"}
  ]

  def options(:unread_alert), do: [
    {"on", "On"},
    {"off", "Off"},
    {"preferences", "Use account preference"}
  ]

end
