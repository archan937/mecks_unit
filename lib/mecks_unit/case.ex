defmodule MecksUnit.Case do
  defmacro mocked_test(env, message, block) do
    quote do
      test unquote(message) do
        MecksUnit.Server.register_mock_env(self(), unquote(env))
        unquote(block)
        MecksUnit.Server.unregister_mock_env(self())
      end
    end
  end
end
