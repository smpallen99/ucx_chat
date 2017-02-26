defmodule UcxChat.Config.Message do
  use UcxChat.Web, :model

  embedded_schema do
    field :allow_message_editing, :boolean, default: true
    field :allow_message_deleting, :boolean, default: true
  end

  @fields [:allow_message_editing, :allow_message_deleting]

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
  end

end
