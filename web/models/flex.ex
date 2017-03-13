defmodule UcxChat.Flex do
  # @mod __MODULE__

  @default_callbacks %{}

  @doc """
  Create a new Flex data item
  """
  def new, do: %{o: %{}, t: %{}, c: %{}}

  @doc """
  Is any tab currently open?

  ## Examples

      iex> alias UcxChat.Flex
      iex> fl = Flex.new()
      iex> Flex.open?(fl, 1)
      false
      iex> Flex.toggle(fl, 1, "Info") |> Flex.open?(1)
      true
  """
  def open?(fl, ch), do: !!get_in(fl, [:o, ch])

  @doc """
  Is a specified tab currently open?

  ## Examples

      iex> alias UcxChat.Flex
      iex> fl = Flex.new()
      iex> Flex.open?(fl, 1)
      false
      iex> Flex.toggle(fl, 1, "Info") |> Flex.open?(1, "Info")
      true
      iex> Flex.toggle(fl, 1, "Info") |> Flex.open?(1, "other")
      false
  """
  def open?(fl, ch, name), do: open_tab_name(fl, ch) == name

  @doc """
  Returns the name of the currently opened tab

  If a tab is not open, returns nil

  ## Examples

      iex> alias UcxChat.Flex
      iex> fl = Flex.new()
      iex> Flex.open_tab_name(fl, 1)
      nil
      iex> Flex.toggle(fl, 1, "Info") |> Flex.open_tab_name(1)
      "Info"
  """
  def open_tab_name(fl, ch) do
    get_in(fl, [:o, ch])
  end

  @doc """
  Toggle a window.

  Opens the window if its closed, otherwise, opens
  the window

  ## Examples

      iex> alias UcxChat.Flex
      iex> fl = Flex.new()
      iex> fl = Flex.toggle(fl, 1, "Info")
      iex> Flex.open?(fl, 1)
      true
      iex> Flex.toggle(fl, 1, "Info") |> Flex.open?(1)
      false
  """
  def toggle(fl, ch, tab, params \\ %{}) do
    open_tab = open_tab_name(fl, ch)
    if open_tab && open_tab == tab do
      close(fl, ch, tab, params)
    else
      open(fl, ch, tab, params)
    end
  end

  @doc """
  Open a tab using its previous state
  """
  def open(fl, ch, tab, params) do
    fl
    |> put_in([:o, ch], tab)
    |> run_callback(ch, tab, get_in(fl, [:t, ch]), params, :open)
  end

  @doc """
  Open a panel in a given flex tab
  """
  def open(fl, ch, tab, panel, params) do
    fl =
      fl
      |> put_in([:o, ch], tab)
      |> put_t(ch, tab, panel)

    run_callback(fl, ch, tab, get_in(fl, [:t, ch]), params, :open)
  end

  @doc """
  Close a flex tab, preserving its state
  """
  def close(fl, ch, tab, params  \\ %{}) do
    fl
    |> put_in([:o, ch], nil)
    |> run_callback(ch, tab, nil, params, :close)
  end

  @doc """
  Back to the main tab window
  """
  def view_all(fl, ch, tab) do
    put_t(fl, ch, tab, nil)
  end

  @doc """
  Shows tab if its open.

  Used when a user changes a page.

  ## Examples
      iex> alias UcxChat.Flex
      iex> fl = Flex.new()
      iex> fl = Flex.toggle(fl, 1, "Info") |> Flex.toggle(2, "Member List")
      iex> Flex.show(fl, 1) |> Flex.open_tab_name(1)
      "Info"
  """

  def show(fl, ch) do
    tab = get_in fl, [:o, ch]
    run_callback(fl, ch, tab, get_in(fl, [:t, ch]), %{}, :open)
    fl
  end

  @doc """
  Returns if a panel is active for a given channel and tab.

  Note that this ignores whether or now the tab is active.
  """
  def panel_active?(fl, ch, tab) do
    case get_in fl, [:t, ch] do
      nil -> false
      map -> !!map[tab]
    end
  end

  defp put_t(fl, ch, tab, panel) do
    update_in fl, [:t, ch], fn
      nil -> Map.put(%{}, tab, panel)
      map -> Map.put(map, tab, panel)
    end
  end

  defp run_callback(fl, ch, tab, panel, socket, state) do
    case get_in fl, [:c, ch]  do
      nil -> default_callbacks(tab).(state, ch, tab, panel, socket)
    end
    fl
  end

  defp default_callbacks(tab) do
    case @default_callbacks[tab] do
      nil -> &default_callback/5
      other -> other
    end
  end

  defp default_callback(state, ch, tab, panel, socket),
    do: send(self(), {:flex, state, ch, tab, panel, socket})
end
