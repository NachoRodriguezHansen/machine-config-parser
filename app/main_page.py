import subprocess
import sys
from pathlib import Path
import streamlit as st
from tabs_manager import Content
from style_manager import AppStyles
from core.utils.definitions import get_supported_series


class MainPage:

    def __init__(self):
        st.set_page_config(
            page_title="Machine Data Viewer",
            layout="wide",
            initial_sidebar_state="expanded"
        )

        with st.sidebar.expander("⚙️ Machine Configuration", expanded=True):
            selected = st.selectbox("Machine Type:", get_supported_series())
            st.session_state.machine_type = selected

        with st.sidebar.expander("🛠️ Actions", expanded=False):
            if st.button("Run Machine Parser"):
                self.run_script_live()

        if "machine_type" in st.session_state:
            selected_machine = st.session_state.machine_type
            tabs = Content(selected_machine)
            tabs.create_tabs()

        AppStyles()
        


    def run_script_live(self):
        """
        Executes machine_config_parser.py in streaming mode,
        piping output live into Streamlit.
        """

        script_path = Path(__file__).parent.parent / "py" / "machine_config_parser.py"

        selected_machine = st.session_state.get("machine_type", "")
        if not selected_machine:
            st.error("No machine type selected.")
            return

        if not script_path.exists():
            st.error(f"Script not found: {script_path}")
            return

        st.markdown("### 🖥️ Live Script Output")
        terminal_box = st.empty()

        command = [
            sys.executable,
            str(script_path),
            "--series",
            selected_machine
        ]

        try:
            process = subprocess.Popen(
                command,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1
            )

            output_text = ""

            # Read stdout in real time
            for line in process.stdout:
                output_text += line
                terminal_box.code(output_text)

            # Read stderr after process ends
            stderr_output = process.stderr.read()
            if stderr_output:
                output_text += "\n--- ERRORS ---\n" + stderr_output
                terminal_box.code(output_text)

            process.wait()

        except Exception as e:
            st.error(f"Error running script: {e}")