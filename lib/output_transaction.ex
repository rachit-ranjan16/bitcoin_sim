defmodule OutputTransaction do
  # 
  # 
  defstruct value: nil, script_pub_key: nil

  def can_be_unlocked_with(%OutputTransaction{} = outx, unlocking_data) do
    IO.puts("O/P PubKey=#{outx.script_pub_key} UnlockingData=#{unlocking_data}")
    outx.script_pub_key === unlocking_data
  end
end
