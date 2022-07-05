defmodule Sapiens.Utils do
  def member?(list_elem, elem) do
    elem.id in for el <- list_elem, do: el.id
  end

  def semestre_atual() do
    1
  end

  def ano_atual() do
    0
  end
end
