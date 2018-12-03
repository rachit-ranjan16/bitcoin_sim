defmodule OutputTransaction do
  @checkSumLen 4
  defstruct value: nil, public_key: nil

  def lock(outx, address) do
    decoded = Base.decode64(address)
    %{outx | public_key: Enum.slice(decoded, 1, length(decoded) - @checSumLen)}
  end

  def can_be_unlocked_with(outx, public_key) do
    # IO.puts("OutX Unlocked=#{outx.public_key === public_key}")
    # outx.public_key_hash === pub_key_hash
    outx.public_key === public_key
  end

  # def can_be_unlocked_with(%OutputTransaction{} = outx, unlocking_data) do
  #   # IO.puts("O/P PubKey=#{outx.script_pub_key} UnlockingData=#{unlocking_data}")
  #   outx.script_pub_key === unlocking_data
  # end
end
