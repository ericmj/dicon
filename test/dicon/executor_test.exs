defmodule Dicon.ExecutorTest do
  use ExUnit.Case

  alias Dicon.Executor

  defmodule FakeExecutor do
    @behaviour Executor

    def connect(:fail), do: {:error, "connect failed"}
    def connect(term), do: {:ok, term}

    def exec(_conn, :fail), do: {:error, "exec failed"}
    def exec(_conn, _command), do: :ok

    def copy(_conn, :fail, :fail), do: {:error, "copy failed"}
    def copy(_conn, _source, _target), do: :ok
  end

  setup_all do
    Application.put_env(:dicon, :executor, FakeExecutor)
    on_exit(fn -> Application.delete_env(:dicon, :executor) end)
  end

  test "connect/1" do
    assert %Executor{} = Executor.connect(:whatever)

    message = "(in Dicon.ExecutorTest.FakeExecutor) connect failed"
    assert_raise Mix.Error, message, fn -> Executor.connect(:fail) end
  end

  test "exec/2" do
    conn = Executor.connect(:whatever)

    assert Executor.exec(conn, :whatever) == :ok

    message = "(in Dicon.ExecutorTest.FakeExecutor) exec failed"
    assert_raise Mix.Error, message, fn -> Executor.exec(conn, :fail) end
  end

  test "copy/2" do
    conn = Executor.connect(:whatever)

    assert Executor.copy(conn, :source, :target) == :ok

    message = "(in Dicon.ExecutorTest.FakeExecutor) copy failed"
    assert_raise Mix.Error, message, fn -> Executor.copy(conn, :fail, :fail) end
  end
end
