
import builtins
import contextlib
import io
import sys
import traceback

code_path = sys.argv[1]
input_path = sys.argv[2]

with open(code_path, "r", encoding="utf-8") as file:
    source_code = file.read()

with open(input_path, "r", encoding="utf-8") as file:
    input_values = iter(file.read().splitlines())

output_buffer = io.StringIO()
original_input = builtins.input


def game_input(prompt=""):
    print(prompt, end="")
    try:
        return next(input_values)
    except StopIteration:
        raise EOFError("No input value provided.")


try:
    with contextlib.redirect_stdout(output_buffer):
        with contextlib.redirect_stderr(output_buffer):
            builtins.input = game_input
            exec(compile(source_code, code_path, "exec"),
                 {"__name__": "__main__"})
except BaseException:
    traceback.print_exc(file=output_buffer)
finally:
    builtins.input = original_input

sys.stdout.write(output_buffer.getvalue())
