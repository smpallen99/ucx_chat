# Copyright (C) E-MetroTel, 2015 - All Rights Reserved
# This software contains material which is proprietary and confidential
# to E-MetroTel and is made available solely pursuant to the terms of
# a written license agreement with E-MetroTel.

defmodule Ucx.Dets do
  @moduledoc """
  Wrapper around the mdse dets table
  """
  @name :chat_dets

  @doc """
  Returns the dets name

  Uses the environment settings to define separate dets names for each
  of the :dev, :test, and :prod environments
  """
  def name do
    @name
  end

  @doc """
  Open the mdse dets table
  """
  def open_file do
    :dets.open_file name(), [auto_save: 30000]
  end

  @doc """
  Look up a value in the mdse dets table

  Returns:
    * the value for simple {key, value} entry
    * the value list if {key, value1, value2, ...} entry
    * [] or default if given
  """
  def lookup(key, default \\ []) do
    case :dets.lookup name(), key do
      [] ->
        default
      [{_, value}] ->
        value
      [tuple] ->
        [_ | value] = Tuple.to_list tuple
        value
    end
  end

  @doc """
  Insert a the value give a key
  """
  def insert(key, value) do
    :dets.insert name(), {key, value}
  end

  @doc """
  Insert a tuple
  """
  def insert(tuple) do
    :dets.insert name(), tuple
  end

  @doc """
  Deletes an entry
  """
  def delete(key) do
    :dets.delete name(), key
    :dets.sync name()
  end

  @doc """
  Deletes all entries
  """
  def delete_all do
    :dets.delete_all_objects name()
    :dets.sync name()
  end

  @doc """
  Return the complete date base
  """
  def all do
    :dets.match name(), :"$1"
  end

  @doc """
  Return the matching entries
  """
  def match(key, value) do
    match {key, value}
  end
  def match(tuple) when is_tuple(tuple) do
    :dets.match name(), tuple
  end

  @doc """
  Deletes matching entries
  """
  def match_delete(pattern) when is_tuple(pattern) do
    :dets.match_delete name(), pattern
  end

  def match_delete(key, value) do
    match_delete name(), {key, value}
  end

end
