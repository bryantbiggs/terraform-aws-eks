import os

# https://mkdocs-macros-plugin.readthedocs.io/en/latest/
# This is used to import code snippets between lines such as:
#   {{ include_file('main.tf', 0, 4) }}

def define_env(env):
    @env.macro
    def include_file(filename, start_line=0, end_line=None):
        """
        Include a file, optionally indicating start_line and end_line (start counting from 0)
        The path is relative to the top directory of the documentation project.
        """
        full_filename = os.path.join(env.project_dir, filename)
        with open(full_filename, 'r') as f:
            lines = f.readlines()
        line_range = lines[start_line:end_line]
        return ''.join(line_range)
