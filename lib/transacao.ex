defmodule Transacao do
  defstruct data: Date.utc_today(), tipo: nil, valor: 0, de: nil, para: nil

  @transacoes "transacoes.txt"

  def gravar(tipo, de, valor, data, para \\ nil) do
    transacoes =
      busca_todas() ++
        [%__MODULE__{tipo: tipo, de: de, valor: valor, data: data, para: para}]

    File.write(@transacoes, :erlang.term_to_binary(transacoes))

    transacoes
  end

  defp busca_todas() do
    {:ok, binario} = File.read(@transacoes)

    :erlang.binary_to_term(binario)
  end
end
