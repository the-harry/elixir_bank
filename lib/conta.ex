defmodule Conta do
  defstruct usuario: Usuario, saldo: nil

  @contas "contas.txt"

  def cadastrar(usuario) do
    case buscar_por_email(usuario.email) do
      nil ->
        binary =
          ([%__MODULE__{usuario: usuario, saldo: 1000}] ++ buscar_contas())
          |> :erlang.term_to_binary()

        File.write(@contas, binary)

      _ ->
        {:error, "conta ja existe."}
    end
  end

  def buscar_contas do
    {:ok, binary} = File.read(@contas)

    :erlang.binary_to_term(binary)
  end

  defp buscar_por_email(email), do: Enum.find(buscar_contas(), &(&1.usuario.email == email))

  def transferir(de, para, valor) do
    de = buscar_por_email(de)
    para = buscar_por_email(para)

    cond do
      valida_saldo(de.saldo, valor) ->
        {:error, "sem saldo"}

      true ->
        contas = Conta.deletar([de, para])

        de = %__MODULE__{de | saldo: de.saldo - valor}
        para = %__MODULE__{para | saldo: para.saldo + valor}

        Transacao.gravar("transferencia", de.usuario.email, valor, Date.utc_today())

        contas = contas ++ [de, para]
        File.write(@contas, :erlang.term_to_binary(contas))
    end
  end

  def deletar(contas) do
    Enum.reduce(contas, buscar_contas(), fn c, acc -> List.delete(acc, c) end)
  end

  def sacar(conta, valor) do
    conta = buscar_por_email(conta)

    cond do
      valida_saldo(conta.saldo, valor) ->
        {:error, "sem saldo"}

      true ->
        contas = buscar_contas()
        contas = List.delete(contas, conta)
        conta = %__MODULE__{conta | saldo: conta.saldo - valor}
        contas = contas ++ [conta]
        File.write(@contas, :erlang.term_to_binary(contas))

        {:ok, conta, "saque efetuado"}
    end
  end

  defp valida_saldo(saldo, valor), do: saldo < valor
end
