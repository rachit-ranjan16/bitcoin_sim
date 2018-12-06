defmodule OutputTransaction do
  @checkSumLen 4
  # public_key: nil,
  defstruct value: nil,
            public_key_hash: nil

  def lock(outx, address) do
    decoded = Base.decode64(address)
    %{outx | public_key: Enum.slice(decoded, 1, length(decoded) - @checSumLen)}
  end

  def can_be_unlocked_with(outx, public_key_hash) do
    IO.puts(
      "OutXPubKeyHash=#{get_printable(outx.public_key_hash)} Incoming public Key hash=#{
        get_printable(public_key_hash)
      }"
    )

    IO.puts("OutX Unlocked=#{outx.public_key_hash === public_key_hash}")
    outx.public_key_hash === public_key_hash
    # outx.public_key === public_key
  end

  # def can_be_unlocked_with(%OutputTransaction{} = outx, unlocking_data) do
  #   # IO.puts("O/P PubKey=#{outx.script_pub_key} UnlockingData=#{unlocking_data}")
  #   outx.script_pub_key === unlocking_data
  # end

  def get_printable(something) do
    # 
    Kernel.inspect(something) |> Base.encode64()
  end
end
