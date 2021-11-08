defmodule Transacao do
  defstruct data: Date.utc_today(), tipo: nil, valor: 0, de: nil, para: nil

  @transacoes "transacoes.txt"

  def gravar(tipo, de, valor, data, para \\ nil) do
    transacoes =
      todas() ++
        [%__MODULE__{tipo: tipo, de: de, valor: valor, data: data, para: para}]

    File.write(@transacoes, :erlang.term_to_binary(transacoes))

    transacoes
  end

  def todas(), do: transacoes()

  def por_ano(ano), do: Enum.filter(transacoes(), &(&1.data.year == ano))

  def por_mes(ano, mes),
    do: Enum.filter(transacoes(), &(&1.data.year == ano && &1.data.month == mes))

  def por_dia(data), do: Enum.filter(transacoes(), &(&1.data == data))

  defp transacoes() do
    {:ok, binario} = File.read(@transacoes)

    :erlang.binary_to_term(binario)
  end

  def calcular_mes(ano, mes), do: calcular(por_mes(ano, mes))

  def calcular_ano(ano), do: calcular(por_ano(ano))

  def calcular_dia(data), do: calcular(por_dia(data))

  defp calcular(transacoes) do
    {transacoes, Enum.reduce(transacoes, 0, fn x, acc -> acc + x.valor end)}
  end
end
