defmodule UcxChat.Config do
  use UcxChat.Web, :model

  @mod __MODULE__

  schema "config" do
    embeds_one :general, UcxChat.Config.General
    embeds_one :message, UcxChat.Config.Message

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> cast_embed(:general)
    |> cast_embed(:message)
    |> validate_required([:general, :message])
  end

  def new_changeset do
    params =
      :embeds
      |> @mod.__schema__
      |> Enum.map(&(@mod.__schema__(:embed, &1)))
      |> Enum.reduce(%{}, fn %Ecto.Embedded{field: field, related: related}, acc ->
        Map.put(acc, field, related.__struct__ |> Map.from_struct)
      end)
    changeset(@mod.__struct__, params)
  end
end
