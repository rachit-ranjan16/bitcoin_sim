defmodule OutputTransaction do
  @checkSumLen 4
  defstruct value: nil, public_key_hash: nil

  def lock(outx, address) do
    decoded = Base.decode64(address)
    %{outx | public_key: Enum.slice(decoded, 1, length(decoded) - @checSumLen)}
  end

  def can_be_unlocked_with(outx, public_key) do
    # IO.puts(
    #   "Outx.Pub_hash=#{Kernel.inspect(outx.public_key_hash) |> Base.encode64()}\n IncomingPublicKey=#{
    #     public_key |> Kernel.inspect() |> Base.encode64()
    #   } \nGeneratedPublicKeyHash=#{
    #     Kernel.inspect(
    #       :crypto.hash(:ripemd160, :crypto.hash(:sha256, public_key))
    #       |> Base.encode64()
    #     )
    #   }"
    # )

    # IO.puts(
    #   "OutX Unlocked=#{
    #     outx.public_key_hash === :crypto.hash(:ripemd160, :crypto.hash(:sha256, public_key))
    #   }"
    # )

    outx.public_key_hash === :crypto.hash(:ripemd160, :crypto.hash(:sha256, public_key))
    # outx.public_key === public_key
  end

  # def can_be_unlocked_with(%OutputTransaction{} = outx, unlocking_data) do
  #   # IO.puts("O/P PubKey=#{outx.script_pub_key} UnlockingData=#{unlocking_data}")
  #   outx.script_pub_key === unlocking_data
  # end
end
